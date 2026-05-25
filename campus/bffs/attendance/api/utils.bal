import ballerina/graphql;
import ballerina/crypto;
import ballerina/http;
import ballerina/log;
import ballerina/mime;
import ballerina/time;
import ballerina/lang.runtime;
import ballerina/io;

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
    string uploadPreset = "Bandaragama_Daily_Attendance";
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

// Send an attendance report via WhatsApp using the attendance_report template
public function sendWhatsAppAttendanceReport(string recipientPhone, string imageUrl, string date) returns json|error {
    http:Client whatsappClient = check new ("https://graph.facebook.com/v22.0/" + WHATSAPP_PHONE_NUMBER_ID);

    json payload = {
        "messaging_product": "whatsapp",
        "to": recipientPhone,
        "type": "template",
        "template": {
            "name": "attendance_report",
            "language": {"code": "en_AE"},
            "components": [
                {
                    "type": "header",
                    "parameters": [
                        {
                            "type": "image",
                            "image": {
                                "link": imageUrl
                            }
                        }
                    ]
                },
                {
                    "type": "body",
                    "parameters": [
                        {
                            "type": "text",
                            "parameter_name": "date",
                            "text": date
                        }
                    ]
                }
            ]
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

// Polls the queue every 100ms.
// If a task is found → process it.
// If queue is empty  → sleep and check again.
// ─────────────────────────────────────────────────────────────────
function processAttendanceQueue() {
    log:printInfo("Attendance queue worker is running...");

    while true {
        AttendanceTask|() task = ();

        // Safely pull one task from the front of the queue
        lock {
            if attendanceQueue.length() > 0 {
                task = attendanceQueue.remove(0);
            }
        }

        if task is AttendanceTask {
            // Task found — process it
            log:printInfo("Worker picked up task for: " + task.userName);
            doProcessAttendance(task);
        } else {
            // Queue is empty — wait 100ms before checking again
            // This prevents a busy loop burning CPU
            runtime:sleep(0.1);
        }
    }
}

function doProcessAttendance(AttendanceTask task) {

    io:println(string `Verified User: ${task.userName}`);

    // ^.*-  Matches everything from the start up to the hyphen
    // \s* Matches any optional spaces
    string nic = re `^.*-\s*`.replace(task.userName, "");
    string formattedDateTime = formatDateTime(task.dateTime);

    GetPersonResponse|graphql:ClientError getPersonResponse = globalDataClient->getPerson(nic);
    if(getPersonResponse is GetPersonResponse) {
        Person|error person_record = getPersonResponse.person_by_digital_id_or_nic.cloneWithType(Person);
        
        if(person_record is Person){
            GetActivityInstancesTodayResponse|graphql:ClientError getActivityInstancesTodayResponse;
            int avinyaType = person_record?.avinya_type_id?: 0;
            io:println("person avinya type:",person_record?.avinya_type_id);
            io:println("person nic:",person_record?.nic_no);

            if(avinyaType==37 || avinyaType==110){
                //Get today activity instance id for students
                getActivityInstancesTodayResponse = globalDataClient->getActivityInstancesToday(4);
            }else{
                getActivityInstancesTodayResponse = globalDataClient->getActivityInstancesToday(1);
            }
            
            if(getActivityInstancesTodayResponse is GetActivityInstancesTodayResponse) {
                var instances = getActivityInstancesTodayResponse.activity_instances_today;
                if instances.length() > 0 {
                    // Access index 0
                    var firstItem = instances[0];
                    
                    // Now you can clone it
                    ActivityInstance|error activityInstance = firstItem.cloneWithType(ActivityInstance);
                    
                    if activityInstance is ActivityInstance{
                        io:println("Found first instance: ", activityInstance?.id);
                        ActivityParticipantAttendance attendance = {
                            activity_instance_id: activityInstance?.id,
                            person_id: person_record?.id,
                            event_time: formattedDateTime
                        };

                        AddBiometricAttendanceResponse|graphql:ClientError addBiometricAttendanceResponse = globalDataClient->addBiometricAttendance(attendance);
                        if(addBiometricAttendanceResponse is AddBiometricAttendanceResponse) {
                            ActivityParticipantAttendance|error attendance_record = addBiometricAttendanceResponse.addBiometricAttendance.cloneWithType(ActivityParticipantAttendance);
                            if(attendance_record is ActivityParticipantAttendance) {
                                log:printInfo("Biometric Attendance Marked Successfully.Person Name:"+task.userName.toString());
                            }else{
                                log:printError("Failed to record biometric attendance. Person Name:"+task.userName.toString());
                            }   
                        }else {
                            log:printError("Failed to record biometric attendance. Person Name:"+task.userName.toString());
                            return;
                        }                                     
                    }
                } else {
                    io:println("No activity instances found for today.");
                }

            }else {
                log:printError("Error while creating the activity instances", getActivityInstancesTodayResponse);
                return;
            }
        }
            
    }else{
        log:printError("Failed to Fetch person from the database");
        // Send the OK back to the device to STOP the looping
        return;
    }

}

function cleanupOldSerialNos(int nowEpoch) {

    // Collect expired keys first
    // cannot remove while iterating — causes runtime error
    string[] keysToRemove = [];

    foreach var [key, storedTime] in processedSerialNos.entries() {
        int ageInSeconds = nowEpoch - storedTime;

        if ageInSeconds > DEDUPE_WINDOW_SECONDS {
            keysToRemove.push(key);
        }
    }
    // remove them safely
    foreach var key in keysToRemove {
        _ = processedSerialNos.remove(key);
        io:println(string `Cleaned up expired serialNo: ${key}`);
        log:printDebug(string `Cleaned up expired serialNo: ${key}`);
    }

}
