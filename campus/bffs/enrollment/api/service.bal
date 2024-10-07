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

    resource function get person_by_id/[int id]() returns Person|error {
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

    resource function get districts() returns District[]|error {
        GetDistrictsResponse|graphql:ClientError getDistrictsResponse = globalDataClient->getDistricts();
        if (getDistrictsResponse is GetDistrictsResponse) {
            District[] districtsData = [];
            foreach var district in getDistrictsResponse.districts {
                District|error districtData = district.cloneWithType(District);
                if (districtData is District) {
                    districtsData.push(districtData);
                } else {
                    log:printError("Error while processing Application record received", districtData);
                    return error("Error while processing Application record received: " + districtData.message() +
                        ":: Detail: " + districtData.detail().toString());
                }
            }

            return districtsData;

        } else {
            log:printError("Error while getting application", getDistrictsResponse);
            return error("Error while getting application: " + getDistrictsResponse.message() +
                ":: Detail: " + getDistrictsResponse.detail().toString());
        }
    }

    resource function get all_organizations() returns Organization[]|error {
        GetAllOrganizationsResponse|graphql:ClientError getAllOrganizationsResponse = globalDataClient->getAllOrganizations();
        if (getAllOrganizationsResponse is GetAllOrganizationsResponse) {
            Organization[] organizationsData = [];
            foreach var organization in getAllOrganizationsResponse.all_organizations {
                Organization|error organizationData = organization.cloneWithType(Organization);
                if (organizationData is Organization) {
                    organizationsData.push(organizationData);
                } else {
                    log:printError("Error while processing Application record received", organizationData);
                    return error("Error while processing Application record received: " + organizationData.message() +
                        ":: Detail: " + organizationData.detail().toString());
                }
            }

            return organizationsData;

        } else {
            log:printError("Error while getting application", getAllOrganizationsResponse);
            return error("Error while getting application: " + getAllOrganizationsResponse.message() +
                ":: Detail: " + getAllOrganizationsResponse.detail().toString());
        }
    }

    resource function put update_person(@http:Payload Person person) returns Person|error {

        Address? permanent_address = person?.permanent_address;
        Address? mailing_address = person?.mailing_address;
        City? permanent_address_city = permanent_address?.city;
        City? mailing_address_city = mailing_address?.city;

        if(permanent_address is Address){
            permanent_address.city = ();
        }

        if(mailing_address is Address){
            mailing_address.city = ();
        }

        person.permanent_address = ();
        person.mailing_address = ();

        UpdatePersonResponse|graphql:ClientError updatePersonResponse = globalDataClient->updatePerson(person, permanent_address_city, mailing_address, permanent_address, mailing_address_city);
        if (updatePersonResponse is UpdatePersonResponse) {
            Person|error person_record = updatePersonResponse.update_person.cloneWithType(Person);
            if (person_record is Person) {
                return person_record;
            }
            else {
                return error("Error while processing Application record received: " + person_record.message() +
                    ":: Detail: " + person_record.detail().toString());
            }
        } else {
            log:printError("Error while updating record", updatePersonResponse);
            return error("Error while updating record: " + updatePersonResponse.message() +
                ":: Detail: " + updatePersonResponse.detail().toString());
        }
    }

    resource function post add_person(@http:Payload Person person) returns Person|error {

        Address? mailing_address = person?.mailing_address;
        City? mailing_address_city = mailing_address?.city;

        if(mailing_address is Address){
            mailing_address.city = ();
        }

        person.mailing_address = ();

        InsertPersonResponse|graphql:ClientError addPersonResponse = globalDataClient->insertPerson(person,mailing_address,mailing_address_city);
        if (addPersonResponse is InsertPersonResponse) {
            Person|error person_record = addPersonResponse.insert_person.cloneWithType(Person);
            if (person_record is Person) {
                return person_record;
            } else {
                log:printError("Error while processing Application record received", person_record);
                return error("Error while processing Application record received: " + person_record.message() +
                    ":: Detail: " + person_record.detail().toString());
            }
        } else {
            log:printError("Error while creating application", addPersonResponse);
            return error("Error while creating application: " + addPersonResponse.message() +
                ":: Detail: " + addPersonResponse.detail().toString());
        }
    }
}
