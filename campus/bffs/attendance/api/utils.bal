import ballerina/graphql;
import ballerina/crypto;
import ballerina/http;
import ballerina/log;
import ballerina/mime;
import ballerina/time;

public configurable boolean GLOBAL_DATA_USE_AUTH = true;
public configurable string GLOBAL_DATA_API_URL = "http://localhost:4000/graphql";
public configurable string CHOREO_TOKEN_URL = "https://id.choreo.dev/oauth2/token";
public configurable string GLOBAL_DATA_CLIENT_ID = "undefined";
public configurable string GLOBAL_DATA_CLIENT_SECRET = "undefined";
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

function formatDateTime(string isoDateTime) returns string {
    // Replace 'T' with space, then remove everything from '+' to the end
    string step1 = re `T`.replace(isoDateTime, " ");
    string result = re `\+.*$`.replace(step1, "");
    return result;
}

// Helper function to keep code clean
function createErrorResponse(int status, string message) returns http:Response {
    http:Response res = new;
    res.statusCode = status;
    res.setPayload({"error": message});
    return res;
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
