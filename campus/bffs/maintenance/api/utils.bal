import ballerina/graphql;
import ballerina/http;
import ballerina/log;
import ballerina/regex;

public configurable boolean GLOBAL_DATA_USE_AUTH = true;
public configurable string GLOBAL_DATA_API_URL = "http://localhost:4000/graphql";
public configurable string CHOREO_TOKEN_URL = "https://id.choreo.dev/oauth2/token";
public configurable string GLOBAL_DATA_CLIENT_ID = "undefined";
public configurable string GLOBAL_DATA_CLIENT_SECRET = "undefined";
configurable string GEMINI_API_KEY = ?;
configurable string GEMINI_URL = ?;

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
