import ballerina/crypto;
import ballerina/graphql;
import ballerina/http;
import ballerina/log;
import ballerina/mime;
import ballerina/regex;
import ballerina/time;

public configurable boolean GLOBAL_DATA_USE_AUTH = true;
public configurable string GLOBAL_DATA_API_URL = "http://localhost:4000/graphql";
public configurable string CHOREO_TOKEN_URL = "https://id.choreo.dev/oauth2/token";
public configurable string GLOBAL_DATA_CLIENT_ID = "undefined";
public configurable string GLOBAL_DATA_CLIENT_SECRET = "undefined";
configurable string GEMINI_API_KEY = ?;
configurable string GEMINI_URL = ?;
configurable string CLOUDINARY_CLOUD_NAME = ?;
configurable string CLOUDINARY_API_KEY = ?;
configurable string CLOUDINARY_API_SECRET = ?;
configurable string WHATSAPP_PHONE_NUMBER_ID = ?;
configurable string WHATSAPP_ACCESS_TOKEN = ?;

type OperationResponse record {| anydata...; |}|record {| anydata...; |}[]|boolean|string|int|float|();

type DataResponse record {|
   map<json?> __extensions?;
   OperationResponse ...;
|};

isolated function performDataBinding(json graphqlResponse, typedesc<DataResponse> targetType)
                                    returns DataResponse|graphql:RequestError {
    do {
        map<json> responseMap = <map<json>>graphqlResponse;
        json responseData = responseMap.get("data");
        if (responseMap.hasKey("extensions")) {
            responseData = check responseData.mergeJson({"__extensions": responseMap.get("extensions")});
        }
        DataResponse response = check responseData.cloneWithType(targetType);
        return response;
    } on fail var e {
        return error graphql:RequestError("GraphQL Client Error", e);
    }
}

// Converts Sinhala chars to \uXXXX safe strings
public function escapeUnicode(string input) returns string {
    string output = "";
    foreach var ch in input {
        int cp = ch.getCodePoint(0);
        if (cp > 127) {
            string hex = cp.toHexString();
            while (hex.length() < 4) {
                hex = "0" + hex;
            }
            output = output + "\\u" + hex;
        } else {
            output = output + ch;
        }
    }
    return output;
}

// Translation helper (with UTF-8 byte reader)
public function translateWithGemini(string[] texts) returns map<string>|error {
    http:Client geminiEndpoint = check new (GEMINI_URL);
    
    string prompt = string `
    Role: Translator (English to Sinhala).
    Output Format: JSON Array of Objects [{"k": "English", "v": "Sinhala"}].
    Strict Rules: Do NOT translate the key "k". Only translate "v". Do not use any English letter!
    TASK: Translate the following list of maintenance tasks into colloquial, spoken Sinhala (as used in daily conversation).
    Tone: Informal and direct. Avoid bookish/formal words (e.g., use 'හදන්න' instead of 'ප්‍රතිසංස්කරණය කරන්න'). Give like normal professional commands, not in a rude tone, For eg instead of using කරනවා use කරන්න. And use common English words in sinhala like වොෂ් රූම්.
    Input: ${texts.toJsonString()}
    `;

    json payload = {
        "contents": [{
            "role": "user",
            "parts": [{ "text": prompt }]
        }]
    };

    http:Request req = new;
    req.setJsonPayload(payload);
    req.setHeader("Content-Type", "application/json");
    req.setHeader("x-goog-api-key", GEMINI_API_KEY);

    http:Response response = check geminiEndpoint->post("", req);
    
    // Force UTF-8 Decoding
    byte[] payloadBytes = check response.getBinaryPayload();
    string responseStr = check string:fromBytes(payloadBytes);
    json fullGeminiResponse = check responseStr.fromJsonString();
    map<json> responseMap = <map<json>>fullGeminiResponse;

    // 1. Check if Gemini returned an error
    if (responseMap.hasKey("error")) {
        json errorDetails = responseMap.get("error");
        log:printError("Gemini API Error: " + errorDetails.toString());
        return {}; 
    }

    // 2. Safely check for 'candidates'
    if (!responseMap.hasKey("candidates")) {
        log:printError("Gemini Response Invalid: Missing 'candidates' key. Full Response: " + responseStr);
        return {};
    }

    json candidates = responseMap.get("candidates");
    string rawInnerJson = "";

    if (candidates is json[] && candidates.length() > 0) {
        map<json> firstCandidate = <map<json>>candidates[0];
        
        // Check for Safety Blocking
        if (firstCandidate.hasKey("finishReason") && firstCandidate.get("finishReason").toString() == "SAFETY") {
            log:printError("Gemini blocked content due to safety settings.");
            return {};
        }

        if (firstCandidate.hasKey("content")) {
            map<json> content = <map<json>>firstCandidate.get("content");
            json parts = content.get("parts");
            if (parts is json[] && parts.length() > 0) {
                map<json> firstPart = <map<json>>parts[0];
                if (firstPart.hasKey("text")) {
                    rawInnerJson = (firstPart.get("text")).toString();
                }
            }
        }
    }

    if (rawInnerJson == "") {
        log:printError("Gemini response content was empty.");
        return {};
    }

    string cleanJson = regex:replace(rawInnerJson, "```json", "");
    cleanJson = regex:replace(cleanJson, "```", "");
    cleanJson = cleanJson.trim();

    int? startIdx = cleanJson.indexOf("[");
    int? endIdx = cleanJson.lastIndexOf("]");
    
    map<string> translationMap = {};

    if (startIdx is int && endIdx is int) {
        cleanJson = cleanJson.substring(startIdx, endIdx + 1);
        json|error parsedList = cleanJson.fromJsonString();
        
        if (parsedList is json[]) {
            foreach json item in parsedList {
                map<json> obj = <map<json>>item;
                string key = obj.hasKey("k") ? (obj.get("k")).toString() : "";
                string val = obj.hasKey("v") ? (obj.get("v")).toString() : "";
                if (key != "") {
                    translationMap[key] = val;
                }
            }
        }
    }
    
    return translationMap;
}

// Upload an image to Cloudinary using signed upload
public function uploadToCloudinary(string base64Image) returns json|error {
    http:Client cloudinaryClient = check new ("https://api.cloudinary.com/v1_1/" + CLOUDINARY_CLOUD_NAME);

    int timestamp = time:utcNow()[0];
    string uploadPreset = "attendance";
    string publicId = "attendance_" + timestamp.toString();
    string filenameOverride = "attendance_" + timestamp.toString();

    // Build signature string - parameters alphabetically (exclude api_key, file, signature)
    string parametersString = "filename_override=" + filenameOverride 
        + "&public_id=" + publicId 
        + "&timestamp=" + timestamp.toString() 
        + "&upload_preset=" + uploadPreset;
    string signatureString = parametersString + CLOUDINARY_API_SECRET;
    
    byte[] signatureHash = crypto:hashSha1(signatureString.toBytes());
    string signature = signatureHash.toBase16().toLowerAscii();

    // Use JSON payload
    json payload = {
        "file": "data:image/png;base64," + base64Image,
        "api_key": CLOUDINARY_API_KEY,
        "timestamp": timestamp,
        "signature": signature,
        "upload_preset": uploadPreset,
        "public_id": publicId,
        "filename_override": filenameOverride
    };

    http:Request req = new;
    req.setJsonPayload(payload);

    http:Response response = check cloudinaryClient->post("/image/upload", req);
    json responseJson = check response.getJsonPayload();

    // Check for Cloudinary error
    map<json> responseMap = <map<json>>responseJson;
    if (responseMap.hasKey("error")) {
        json errorDetail = responseMap.get("error");
        log:printError("Cloudinary upload error: " + errorDetail.toString());
        return error("Cloudinary upload failed: " + errorDetail.toString());
    }

    return responseJson;
}

// Helper to create a form-data content disposition
function createFormData(string name) returns mime:ContentDisposition {
    mime:ContentDisposition cd = new;
    cd.name = name;
    cd.disposition = "form-data";
    return cd;
}

// Send an image via WhatsApp using the Meta Graph API
public function sendWhatsAppImage(string recipientPhone, string imageUrl, string caption) returns json|error {
    http:Client whatsappClient = check new ("https://graph.facebook.com/v22.0/" + WHATSAPP_PHONE_NUMBER_ID);

    json payload = {
        "messaging_product": "whatsapp",
        "to": recipientPhone,
        "type": "image",
        "image": {
            "link": imageUrl,
            "caption": caption
        }
    };

    http:Request req = new;
    req.setJsonPayload(payload);
    req.setHeader("Authorization", "Bearer " + WHATSAPP_ACCESS_TOKEN);

    http:Response response = check whatsappClient->post("/messages", req);
    json responseJson = check response.getJsonPayload();

    int statusCode = response.statusCode;
    if (statusCode < 200 || statusCode >= 300) {
        log:printError("WhatsApp API error: " + responseJson.toString());
        return error("WhatsApp API error: " + responseJson.toString());
    }

    return responseJson;
}
