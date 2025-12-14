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
}
