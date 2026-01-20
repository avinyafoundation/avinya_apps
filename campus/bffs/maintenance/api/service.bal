import ballerina/graphql;
import ballerina/http;
import ballerina/log;
import ballerina/regex;

configurable string GEMINI_API_KEY = ?;
configurable string GEMINI_URL = ?;
public function initClientConfig() returns ConnectionConfig {
    ConnectionConfig _clientConig = {};
    if (GLOBAL_DATA_USE_AUTH) {
        _clientConig.oauth2ClientCredentialsGrantConfig = {
            tokenUrl: CHOREO_TOKEN_URL,
            clientId: GLOBAL_DATA_CLIENT_ID,
            clientSecret: GLOBAL_DATA_CLIENT_SECRET
        };
    } else {
        _clientConig = {};
    }
    // log:printDebug("debug log");
    // log:printError("error log");
    // log:printInfo("info log");
    // log:printWarn("warn log");
    // log:printInfo("CHOREO_TOKEN_URL: " + CHOREO_TOKEN_URL);
    // log:printInfo("GLOBAL_DATA_CLIENT_ID: " + GLOBAL_DATA_CLIENT_ID);
    // log:printInfo("GLOBAL_DATA_CLIENT_SECRET: " + GLOBAL_DATA_CLIENT_SECRET);
    return _clientConig;
}

final GraphqlClient globalDataClient = check new (GLOBAL_DATA_API_URL,
    config = initClientConfig()
);

@http:ServiceConfig {
    cors: {
        allowOrigins: ["*"]
    }
}
service / on new http:Listener(9097) {

    //Add a new academy location for the given organization[bandaragama,etc..]
    resource function post organizations/[int organizationId]/locations(@http:Payload OrganizationLocation organizationLocation) returns OrganizationLocation|ApiErrorResponse|error {
        SaveOrganizationLocationResponse|graphql:ClientError saveOrganizationLocationResponse = globalDataClient->saveOrganizationLocation(organizationId,organizationLocation);
        if(saveOrganizationLocationResponse is SaveOrganizationLocationResponse) {
            OrganizationLocation|error organizationLocationRecord = saveOrganizationLocationResponse.saveOrganizationLocation.cloneWithType(OrganizationLocation);
            if(organizationLocationRecord is OrganizationLocation) {
                return organizationLocationRecord;
            } else {
                log:printError("Error while adding organization location record", organizationLocationRecord);
                return <ApiErrorResponse>{body: { message: "Error while adding organization location record" }};
            }
        } else {
            log:printError("Error while adding organization location", saveOrganizationLocationResponse);
            return <ApiErrorResponse>{body: { message: "Error while adding adding organization location record" }};
        }
    }
    
    //Getting Organization Locations by Org Id
    resource function get organizations/[int organizationId]/locations() returns OrganizationLocation[]|error {
        GetLocationsByOrganizationResponse|graphql:ClientError getLocationsByOrganizationResponse = globalDataClient->getLocationsByOrganization(organizationId);
        if(getLocationsByOrganizationResponse is GetLocationsByOrganizationResponse) {
            OrganizationLocation[]  organizationLocations = [];
            foreach var org_location_record in getLocationsByOrganizationResponse.locationsByOrganization {
                OrganizationLocation|error orgLocation = org_location_record.cloneWithType(OrganizationLocation);
                if(orgLocation is OrganizationLocation) {
                    organizationLocations.push(orgLocation);
                } else {
                    log:printError("Error while getting organization location record", orgLocation);
                    return error("Error while getting organization location record: " + orgLocation.message() + 
                        ":: Detail: " + orgLocation.detail().toString());
                }
            }

            return organizationLocations;
            
        } else {
            log:printError("Error while getting organization locations", getLocationsByOrganizationResponse);
            return error("Error while getting organization locations: " + getLocationsByOrganizationResponse.message() + 
                ":: Detail: " + getLocationsByOrganizationResponse.detail().toString());
        }
    }
    
    //Getting Organization Employees[Bandaragama Employees]
    resource function get organizations/[int organizationId]/persons() returns Person[]|error {
        GetEmployeesByOrganizationResponse|graphql:ClientError getEmployeesByOrganizationResponse = globalDataClient->getEmployeesByOrganization(organizationId,());
        if(getEmployeesByOrganizationResponse is GetEmployeesByOrganizationResponse) {
            Person[]  personsData = [];
            foreach var person_record in getEmployeesByOrganizationResponse.persons {
                Person|error personData = person_record.cloneWithType(Person);
                if(personData is Person) {
                    personsData.push(personData);
                } else {
                    log:printError("Error while getting person record", personData);
                    return error("Error while getting person record: " + personData.message() + 
                        ":: Detail: " + personData.detail().toString());
                }
            }

            return personsData;
            
        } else {
            log:printError("Error while getting persons data", getEmployeesByOrganizationResponse);
            return error("Error while getting persons data: " + getEmployeesByOrganizationResponse.message() + 
                ":: Detail: " + getEmployeesByOrganizationResponse.detail().toString());
        }
    }

    //Creates a new maintenance task for the specified organization[bandaragama,etc..]
    resource function post organizations/[int organizationId]/tasks(@http:Payload MaintenanceTask maintenanceTask) returns MaintenanceTask|ApiErrorResponse|error {
        
        MaintenanceFinance? finance = maintenanceTask?.finance ?:();
        MaterialCost[]? material_costs= ();
        if(finance is MaintenanceFinance){
          material_costs = finance?.materialCosts;
          finance.materialCosts = ();
        }
        maintenanceTask.finance = ();

        CreateMaintenanceTaskResponse|graphql:ClientError createMaintenanceTaskResponse = globalDataClient->createMaintenanceTask(organizationId,maintenanceTask,material_costs,finance);
        if(createMaintenanceTaskResponse is CreateMaintenanceTaskResponse) {
            MaintenanceTask|error maintenanceTaskRecord = createMaintenanceTaskResponse.createMaintenanceTask.cloneWithType(MaintenanceTask);
            if(maintenanceTaskRecord is MaintenanceTask) {
                return maintenanceTaskRecord;
            } else {
                log:printError("Error while adding maintenance task record", maintenanceTaskRecord);
                return <ApiErrorResponse>{body: { message: "Error while adding maintenance task record" }};
            }
        } else {
            log:printError("Error while adding maintenance task record", createMaintenanceTaskResponse);
            return <ApiErrorResponse>{body: { message: "Error while adding maintenance task record" }};
        }
    }

    //Getting Maintenance Tasks for the specified organization with optional filters
    resource function get organizations/[int organizationId]/tasks(
        int[]? personId = (),
        string? fromDate = (),
        string? toDate = (),
        string? taskStatus = (),
        string? financialStatus = (),
        string? taskType = (),
        int? location = (),
        string? title = (),
        int 'limit = 10,
        int offset = 0
    ) returns ActivityInstance[]|error {
        MaintenanceTasksResponse|graphql:ClientError maintenanceTasksResponse = globalDataClient->MaintenanceTasks(
            organizationId,
            offset,
            'limit,
            fromDate,
            taskType,
            toDate,
            financialStatus,
            personId,
            location,
            title,
            taskStatus
        );
        if (maintenanceTasksResponse is MaintenanceTasksResponse) {
            ActivityInstance[] activityInstances = [];
            var tasks = maintenanceTasksResponse?.maintenanceTasks;
            if (tasks is ()) {
                return <ActivityInstance[]>[];
            }
            foreach var task_record in tasks {
                ActivityInstance|error activityInstance = task_record.cloneWithType(ActivityInstance);
                if (activityInstance is ActivityInstance) {
                    activityInstances.push(activityInstance);
                } else {
                    log:printError("Error while getting activity instance record", activityInstance);
                    return error("Error while getting activity instance record: " + activityInstance.message() +
                        ":: Detail: " + activityInstance.detail().toString());
                }
            }
            return activityInstances;
        } else {
            log:printError("Error while getting maintenance tasks", maintenanceTasksResponse);
            return error("Error while getting maintenance tasks: " + maintenanceTasksResponse.message() +
                ":: Detail: " + maintenanceTasksResponse.detail().toString());
        }
    }

    //Getting Overdue Maintenance Tasks for the specified organization
    resource function get tasks/[int organizationId]/overdue(
        int 'limit = 10,
        int offset = 0
    ) returns ActivityInstance[]|error {
        GetOverdueMaintenanceTasksResponse|graphql:ClientError overdueTasksResponse = globalDataClient->GetOverdueMaintenanceTasks(organizationId);
        if (overdueTasksResponse is GetOverdueMaintenanceTasksResponse) {
            ActivityInstance[] activityInstances = [];
            var tasks = overdueTasksResponse?.overdueMaintenanceTasks;
            if (tasks is ()) {
                return <ActivityInstance[]>[];
            }
            foreach var task_record in tasks {
                ActivityInstance|error activityInstance = task_record.cloneWithType(ActivityInstance);
                if (activityInstance is ActivityInstance) {
                    activityInstances.push(activityInstance);
                } else {
                    log:printError("Error while getting overdue activity instance record", activityInstance);
                    return error("Error while getting overdue activity instance record: " + activityInstance.message() +
                        ":: Detail: " + activityInstance.detail().toString());
                }
            }
            return activityInstances;
        } else {
            log:printError("Error while getting overdue maintenance tasks", overdueTasksResponse);
            return error("Error while getting overdue maintenance tasks: " + overdueTasksResponse.message() +
                ":: Detail: " + overdueTasksResponse.detail().toString());
        }
    }

    //Deactivate a maintenance task by its ID
    resource function put tasks/[int taskId](
        string modifiedBy
    ) returns MaintenanceTask
        | ApiErrorResponse | error {

        SoftDeactivateMaintenanceTaskResponse|graphql:ClientError response =
            globalDataClient->SoftDeactivateMaintenanceTask(modifiedBy, taskId);

        if (response is SoftDeactivateMaintenanceTaskResponse) {
            var result = response.softDeactivateMaintenanceTask;
            if (result is ()) {
                return <ApiErrorResponse>{ body: { message: "Task not found or already deactivated" } };
            }
            return result;
        } else {
            log:printError("Error soft deactivating maintenance task", response);
            return <ApiErrorResponse>{ body: { message: response.message() } };
        }
    }

    //Update finance status for a task
    resource function put organizations/[int organizationId]/tasks/finance/[int financeId](
        @http:Payload MaintenanceFinance maintenanceFinance
    ) returns MaintenanceFinance
        | ApiErrorResponse | error {

        UpdateMaintenanceFinanceResponse|graphql:ClientError response =
            globalDataClient->UpdateMaintenanceFinance(financeId, maintenanceFinance);

        if (response is UpdateMaintenanceFinanceResponse) {
            var result = response.updateMaintenanceFinance;
            if (result is ()) {
                return <ApiErrorResponse>{ body: { message: "No update result returned" } };
            }
            return result;
        } else {
            log:printError("Error updating maintenance finance", response);
            return <ApiErrorResponse>{ body: { message: response.message() } };
        }
    }

    //Get monthly maintenance task summary
    resource function get organizations/[int organizationId]/reports/monthly/[int year]/[int month]() returns GetMonthlyMaintenanceReportResponse | error {

        GetMonthlyMaintenanceReportResponse|graphql:ClientError response =
            globalDataClient->GetMonthlyMaintenanceReport(organizationId, month, year);

        if (response is GetMonthlyMaintenanceReportResponse) {
            return response;
        } else {
            log:printError("Error fetching monthly maintenance report", response);
            return error(response.message());
        }
    }

    //Get tasks by month, year and status
    resource function get organizations/[int organizationId]/reports/monthly/[int year]/[int month]/tasks(
        string? overallTaskStatus = (),
        int 'limit = 10,
        int offset = 0
    ) returns ActivityInstance[] | error {

        MaintenanceTasksByStatusResponse|graphql:ClientError response =
            globalDataClient->MaintenanceTasksByStatus(
                organizationId,
                month,
                offset,
                year,
                'limit,
                overallTaskStatus
            );

        if (response is MaintenanceTasksByStatusResponse) {
            var tasks = response.maintenanceTasksByMonthYearStatus;
            if (tasks is ()) {
                return [];
            }
            return tasks;
        } else {
            log:printError("Error fetching maintenance tasks by status", response);
            return error(response.message());
        }
    }

    resource function get organizations/[int organizationId]/getTasksByStatus(
        int? personId = (),
        string? fromDate = (),
        string? toDate = (),
        string? taskType = (),
        int? location = ()
    ) returns ActivityInstance[]|error {

        GetMaintenanceTasksByStatusResponse|graphql:ClientError statusResponse = 
            globalDataClient->GetMaintenanceTasksByStatus(
                organizationId, 
                fromDate, 
                taskType, 
                toDate, 
                personId, 
                location
            );

        if (statusResponse is GetMaintenanceTasksByStatusResponse) {
            ActivityInstance[] activityInstances = [];
            var dataGroups = statusResponse?.maintenanceTasksByStatus?.groups;

            if (dataGroups.length() == 0) {
                return <ActivityInstance[]>[];
            }

            foreach var task_record in dataGroups {
                ActivityInstance|error activityInstance = task_record.cloneWithType(ActivityInstance);
                
                if (activityInstance is ActivityInstance) {
                    activityInstances.push(activityInstance);
                } else {
                    log:printError("Error while binding ActivityInstance record", activityInstance);
                    return error("Error while binding ActivityInstance record: " + activityInstance.message() +
                        ":: Detail: " + activityInstance.detail().toString());
                }
            }

            return activityInstances;

        } else {
            log:printError("Error while getting maintenance tasks by status", statusResponse);
            return error("Error while getting maintenance tasks by status: " + statusResponse.message() +
                ":: Detail: " + statusResponse.detail().toString());
        }
    }

    resource function get tasks/[int organizationId]/monthlyCostSummary/[int year]() 
        returns GetMonthlyCostSummaryResponse|error {

        GetMonthlyCostSummaryResponse|graphql:ClientError summaryResponse = globalDataClient->GetMonthlyCostSummary(organizationId, year);

        if (summaryResponse is GetMonthlyCostSummaryResponse) {
            return summaryResponse ;
        } else {
            log:printError("Error while getting monthly cost summary", summaryResponse);
            return error("Error while getting monthly cost summary: " + summaryResponse.message() +
                ":: Detail: " + summaryResponse.detail().toString());
        }
    }

    //Get monthly actual cost and estimated cost for activity instances grouped by maintenance task
    resource function get organizations/[int organizationId]/reports/monthly/[int year]/[int month]/costs()
        returns MonthlyTaskCostReportResponse | error {

        MonthlyTaskCostReportResponse|graphql:ClientError response =
            globalDataClient->MonthlyTaskCostReport(
                organizationId,
                month,
                year
            );

        if (response is MonthlyTaskCostReportResponse) {
            return response;
        } else {
            log:printError(
                "Error fetching monthly task cost report",
                response
            );
            return error(response.message());
        }
    }

    //Maintenance task edit rest api
    resource function put organizations/[int organizationId]/tasks(@http:Payload ActivityInstance taskActivityInstance) returns ActivityInstance|error {
       
        int[] personIds = [];

        MaintenanceTask maintenanceTask = taskActivityInstance?.maintenanceTask ?: {};
        MaintenanceFinance? finance = taskActivityInstance?.financialInformation ?:();
        ActivityParticipant[] taskParticipants = taskActivityInstance?.activityParticipants ?:[];
        
        //take and put each person db raw id into the array.
        if(taskParticipants is ActivityParticipant[]) {
            foreach var participant in taskParticipants {
                Person? person = participant?.person;  
                if person is Person{
                    personIds.push(person?.id ?: 0);
                }
            }
        }
        
        MaterialCost[]? material_costs= ();
        if(finance is MaintenanceFinance){
          material_costs = finance?.materialCosts;
          finance.materialCosts = ();
        }
        taskActivityInstance.financialInformation = ();
        taskActivityInstance.maintenanceTask = ();
        taskActivityInstance.activityParticipants = ();

        UpdateMaintenanceTaskResponse|graphql:ClientError updateMaintenanceTaskResponse = globalDataClient->
                                                                                       updateMaintenanceTask(
                                                                                        organizationId,
                                                                                        personIds,
                                                                                        taskActivityInstance,
                                                                                        maintenanceTask,
                                                                                        material_costs,
                                                                                        finance);
        if (updateMaintenanceTaskResponse is UpdateMaintenanceTaskResponse) {
            ActivityInstance|error task_record = updateMaintenanceTaskResponse.updateMaintenanceTask.cloneWithType(ActivityInstance);
            if (task_record is ActivityInstance) {
                return task_record;
            }
            else {
                return error("Error while updating the task record: " + task_record.message() +
                    ":: Detail: " + task_record.detail().toString());
            }
        } else {
            log:printError("Error while updating record", updateMaintenanceTaskResponse);
            return error("Error while updating record: " + updateMaintenanceTaskResponse.message() +
                ":: Detail: " + updateMaintenanceTaskResponse.detail().toString());
        }
    }
    
    //update the task participant task progress
    resource function patch tasks/activity_instances/[int activityInstanceId]/participants/[int personId]
(@http:Payload ActivityParticipant activityParticipant) returns ActivityParticipant|ApiErrorResponse|error {

        UpdateTaskProgressResponse|graphql:ClientError updateTaskProgressResponse = globalDataClient->updateTaskProgress(personId,activityParticipant,activityInstanceId);
        
        if(updateTaskProgressResponse is  UpdateTaskProgressResponse) {

            ActivityParticipant|error activityParticipantRecord = updateTaskProgressResponse.updateTaskProgress.cloneWithType(ActivityParticipant);
            
            if(activityParticipantRecord is  ActivityParticipant) {

                return activityParticipantRecord;

            } else {
                log:printError("Error while updating the task participant task progress",activityParticipantRecord);
                return <ApiErrorResponse>{body: { message: "Error while updating the participant task progress" }};
            }
        } else {
            log:printError("Error while updating the task participant task progress",updateTaskProgressResponse);
            return <ApiErrorResponse>{body: { message: "Error while updating the task participant task progress" }};
        }
    }    

    resource function get organizations/[int organizationId]/getSinhalaTasks(
        int? personId = (),
        string? fromDate = (),
        string? toDate = (),
        string? taskType = (),
        int? location = ()
    ) returns json|error {

        // 1. Fetch raw tasks
        GetMaintenanceTasksByStatusResponse|graphql:ClientError statusResponse = 
            globalDataClient->GetMaintenanceTasksByStatus(
                organizationId, fromDate, taskType, toDate, personId, location
            );

        if (statusResponse is graphql:ClientError) {
            return error("GraphQL Error: " + statusResponse.message());
        }

        var dataGroups = statusResponse.maintenanceTasksByStatus.groups;
        
        // 2. Collect text
        string[] textsToTranslate = [];
        foreach var group in dataGroups {
            foreach var taskRecord in group.tasks {
                var task = taskRecord.task;
                if (task != ()) {
                    string? title = task.title;
                    if (title is string && title != "" && textsToTranslate.indexOf(title) == ()) {
                        textsToTranslate.push(title);
                    }
                    string? desc = task.description;
                    if (desc is string && desc != "" && textsToTranslate.indexOf(desc) == ()) {
                        textsToTranslate.push(desc);
                    }
                }
            }
        }

        // 3. Translate
        map<string> translations = {};
        if (textsToTranslate.length() > 0) {
            translations = check self.translateWithGemini(textsToTranslate);
        }

        // 4. Construct JSON Response
        json[] groupsJson = [];
        foreach var group in dataGroups {
            json[] tasksJson = [];
            foreach var taskRecord in group.tasks {
                var task = taskRecord.task;
                
                string translatedTitle = "";
                string translatedDesc = "";
                
                if (task != ()) {
                    string? title = task.title;
                    if (title is string) {
                        string rawTitle = translations.hasKey(title) ? translations.get(title) : title;
                        // FIX: Escape to Unicode (\uXXXX) before sending
                        translatedTitle = self.escapeUnicode(rawTitle);
                    }
                    string? desc = task.description;
                    if (desc is string) {
                        string rawDesc = translations.hasKey(desc) ? translations.get(desc) : desc;
                        translatedDesc = self.escapeUnicode(rawDesc);
                    }
                }
                
                json taskRefJson = ();
                if (task != ()) {
                     var loc = task.location;
                     taskRefJson = {
                        "id": task.id,
                        "title": translatedTitle,
                        "description": translatedDesc,
                        "location": loc != () ? {
                             "id": loc.id,
                             "location_name": loc.location_name
                        } : ()
                     };
                }

                json taskItem = {
                    "id": taskRecord.id,
                    "end_time": taskRecord.end_time,
                    "statusText": taskRecord.statusText,
                    "overdue_days": taskRecord.overdue_days,
                    "task": taskRefJson
                };
                tasksJson.push(taskItem);
            }

            groupsJson.push({
                "groupId": group.groupId,
                "groupName": group.groupName,
                "tasks": tasksJson
            });
        }

        return groupsJson;
    }

    //  NEW HELPER: Converts Sinhala chars to \uXXXX safe strings
    private function escapeUnicode(string input) returns string {
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

    //  TRANSLATION HELPER (With UTF-8 Byte Reader)
    private function translateWithGemini(string[] texts) returns map<string>|error {
        http:Client geminiEndpoint = check new (GEMINI_URL);
        
        string prompt = string `
        Role: Translator (English to Sinhala).
        Output Format: JSON Array of Objects [{"k": "English", "v": "Sinhala"}].
        Strict Rules: Do NOT translate the key "k". Only translate "v". Do not use any English letter!
        TASK: Translate the following list of maintenance tasks into colloquial, spoken Sinhala (as used in daily conversation).
        Tone: Informal and direct. Avoid bookish/formal words (e.g., use 'හදන්න' instead of 'ප්‍රතිසංස්කරණය කරන්න'). Give like normal professional commands, For eg instead of using කරනවා use කරන්න
        Technical Terms: Keep common English terms as-is or transliterate them if they are used locally (e.g., 'AC', 'Generator', 'Washroom', 'Sink', 'Lift'). 
        Examples: For example use "වොෂ් රූම් එකේ වතුර ලීක් එක හදන්න" for "Fix the leak in the washroom", "කැඩිච්ච සින්ක් එක හදන්න" for "Repair the broken sink", instead of a formal translation.
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
}
