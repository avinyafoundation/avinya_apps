import ballerina/http;
import ballerina/graphql;
import ballerina/log;


public function initClientConfig() returns ConnectionConfig{
    ConnectionConfig _clientConig = {};
    if (GLOBAL_DATA_USE_AUTH) {
        _clientConig.oauth2ClientCredentialsGrantConfig =  {
            tokenUrl: CHOREO_TOKEN_URL,
            clientId:GLOBAL_DATA_CLIENT_ID,
            clientSecret:GLOBAL_DATA_CLIENT_SECRET
        };
    } else { 
        _clientConig = {};
    }
    return _clientConig;
}


final GraphqlClient globalDataClient = check new (GLOBAL_DATA_API_URL,
    config = initClientConfig()
);

# A service representing a network-accessible API
# bound to port `9091`.
@http:ServiceConfig {
    cors: {
        allowOrigins: ["*"]
    }
}
service / on new http:Listener(9090) {

    # A resource for generating greetings
    # + name - the input string name
    # + return - string name with hello message or error
    resource function get greeting(string name) returns string|error {
        // Send a response back to the caller.
        if name is "" {
            return error("name should not be empty!");
        }
        return "Hello, " + name;
    }

    # Person resource for getting person details given the digitial ID 
    # + digital_id - is the Asgardeo ID of the user which is also the official email address
    # + return - Person record for the given digital ID or error
    resource function get person(string digital_id) returns Person|error {

        GetPersonResponse|graphql:ClientError getPersonResponse = globalDataClient->getPerson(digital_id);
        if(getPersonResponse is GetPersonResponse) {
            Person|error person_record = getPersonResponse.person_by_digital_id.cloneWithType(Person);
            if(person_record is Person) {
                return person_record;
            } else {
                log:printError("Error while processing Application record received1", person_record);
                return error("Error while processing Person record received2: " + person_record.message() + 
                    ":: Detail: " + person_record.detail().toString());
            }
        } else {
            log:printError("Error while fetching person records application3", getPersonResponse);
            return error("Error while fetching person records application4: " + getPersonResponse.message() + 
                ":: Detail: " + getPersonResponse.detail().toString());
        }
    }

    resource function get student_list_by_parent_org_id(int id) returns Person[]|error {

        GetStudentByParentOrgResponse|graphql:ClientError getPersonResponse = globalDataClient->getStudentByParentOrg(id);
        if(getPersonResponse is GetStudentByParentOrgResponse) {
            Person[] studdents = [];
            foreach var person_record in getPersonResponse.student_list_by_parent {
                Person|error person = person_record.cloneWithType(Person);
                if(person is Person) {
                    studdents.push(person);
                } else {
                    log:printError("Error while processing Person record received", person);
                    return error("Error while processing Person record received: " + person.message() + 
                        ":: Detail: " + person.detail().toString());
                }
            }
            return studdents;
        } else {
            log:printError("Error while fetching person records application3", getPersonResponse);
            return error("Error while fetching person records application4: " + getPersonResponse.message() + 
                ":: Detail: " + getPersonResponse.detail().toString());
        }
    }

    resource function get organization(int id) returns Organization|error {
        GetOrganizationResponse|graphql:ClientError getOrganizationResponse = globalDataClient->getOrganization(id);
        if(getOrganizationResponse is GetOrganizationResponse) {
            Organization|error organization_record = getOrganizationResponse.organization.cloneWithType(Organization);
            if(organization_record is Organization) {
                return organization_record;
            } else {
                log:printError("Error while processing Application record received1", organization_record);
                return error("Error while processing Organization record received2: " + organization_record.message() + 
                    ":: Detail: " + organization_record.detail().toString());
            }
        } else {
            log:printError("Error while fetching organization records application3", getOrganizationResponse);
            return error("Error while fetching organization records application4: " + getOrganizationResponse.message() + 
                ":: Detail: " + getOrganizationResponse.detail().toString());
        }
    }
    
}
