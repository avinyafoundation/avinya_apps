import ballerina/graphql;
import ballerina/http;
import ballerina/log;


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
    ) returns json|error {
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
            var tasks = maintenanceTasksResponse?.maintenanceTasks;
            if (tasks is ()) {
                return <json>[];
            }
            return tasks.toJson();
        } else {
            // GraphQL can return partial data with errors
            // Try to extract data from error detail if available
            string errorDetail = maintenanceTasksResponse.detail().toString();
            if (errorDetail.includes("\"data\":{\"maintenanceTasks\":")) {
                log:printWarn("GraphQL returned data with errors (partial success): " + maintenanceTasksResponse.message());
                // The data is in the error detail, try to parse it
                json|error detailJson = errorDetail.fromJsonString();
                if (detailJson is json) {
                    json|error tasksData = detailJson.data.maintenanceTasks;
                    if (tasksData is json) {
                        return tasksData;
                    }
                }
            }
            log:printError("Error while getting maintenance tasks", maintenanceTasksResponse);
            return error("Error while getting maintenance tasks: " + maintenanceTasksResponse.message() +
                ":: Detail: " + errorDetail);
        }
    }

    //Getting Overdue Maintenance Tasks for the specified organization
    resource function get tasks/[int organizationId]/overdue(
        int 'limit = 10,
        int offset = 0
    ) returns json|error {
        GetOverdueMaintenanceTasksResponse|graphql:ClientError overdueTasksResponse = globalDataClient->GetOverdueMaintenanceTasks(organizationId);
        if (overdueTasksResponse is GetOverdueMaintenanceTasksResponse) {
            var tasks = overdueTasksResponse?.overdueMaintenanceTasks;
            if (tasks is ()) {
                return <json>[];
            }
            return tasks.toJson();
        } else {
            log:printError("Error while getting overdue maintenance tasks", overdueTasksResponse);
            return error("Error while getting overdue maintenance tasks: " + overdueTasksResponse.message() +
                ":: Detail: " + overdueTasksResponse.detail().toString());
        }
    }
}
