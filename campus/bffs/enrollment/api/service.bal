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
service / on new http:Listener(9095) {

    resource function get persons/[int organization_id]/[int avinya_type_id]() returns Person[]|error {
        GetPersonsResponse|graphql:ClientError getPersonsResponse = globalDataClient->getPersons(organization_id, avinya_type_id);
        if (getPersonsResponse is GetPersonsResponse) {
            Person[] person_datas = [];
            foreach var person_data in getPersonsResponse.persons {
                Person|error person_data_record = person_data.cloneWithType(Person);
                if (person_data_record is Person) {
                    person_datas.push(person_data_record);
                } else {
                    log:printError("Error while processing Application record received", person_data_record);
                    return error("Error while processing Application record received: " + person_data_record.message() +
                        ":: Detail: " + person_data_record.detail().toString());
                }
            }

            return person_datas;

        } else {
            log:printError("Error while getting application", getPersonsResponse);
            return error("Error while getting application: " + getPersonsResponse.message() +
                ":: Detail: " + getPersonsResponse.detail().toString());
        }
    }

    resource function get  person_by_id/[int id]() returns Person|error {
        GetPersonByIdResponse|graphql:ClientError getPersonByIdResponse = globalDataClient->getPersonById(id);
        if (getPersonByIdResponse is GetPersonByIdResponse) {
            Person|error person_by_id_record = getPersonByIdResponse.person_by_id.cloneWithType(Person);
            if (person_by_id_record is Person) {
                return person_by_id_record;
            } else {
                log:printError("Error while processing Application record received", person_by_id_record);
                return error("Error while processing Application record received: " + person_by_id_record.message() +
                    ":: Detail: " + person_by_id_record.detail().toString());
            }
        } else {
            log:printError("Error while creating application", getPersonByIdResponse);
            return error("Error while creating application: " + getPersonByIdResponse.message() +
                ":: Detail: " + getPersonByIdResponse.detail().toString());
        }
    }
}
