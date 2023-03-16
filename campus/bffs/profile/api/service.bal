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
service / on new http:Listener(9095) {

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


    resource function get person(string id) returns Person|error {

        GetPersonResponse|graphql:ClientError getPersonResponse = globalDataClient->getPerson(id);
        if(getPersonResponse is GetPersonResponse) {
            Person|error person_record = getPersonResponse.person_by_digital_id.cloneWithType(Person);
            if(person_record is Person) {
                return person_record;
            } else {
                log:printError("Error while processing Application record received1", person_record);
                return error("Error while processing Application record received2: " + person_record.message() + 
                    ":: Detail: " + person_record.detail().toString());
            }
        } else {
            log:printError("Error while creating application3", getPersonResponse);
            return error("Error while creating application4: " + getPersonResponse.message() + 
                ":: Detail: " + getPersonResponse.detail().toString());
        }
    }

//         resource function get person (string id) returns Person|error { 
//         GetPersonResponse|graphql:ClientError getPersonResponse = globalDataClient->getPerson(id); 
//          if(getPersonResponse is GetPersonResponse) {) { 
//  Person|error person_record = getPersonResponse.person_by_jwt.cloneWithType(Person);
//              if(person_record is Person) {
//                 return person_record;
//             } else {
//                 log:printError("Error while processing Application record received1", person_record);
//                 return error("Error while processing Application record received2: " + person_record.message() + 
//                     ":: Detail: " + person_record.detail().toString());
//             }
//          }  else {
//             log:printError("Error while creating application3", getPersonResponse);
//             return error("Error while creating application4: " + getPersonResponse.message() + 
//                 ":: Detail: " + getPersonResponse.detail().toString());
//         }
//      }

 
 

    
}
