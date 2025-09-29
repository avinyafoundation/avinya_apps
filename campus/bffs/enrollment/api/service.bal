import ballerina/graphql;
import ballerina/http;
import ballerina/io;
import ballerina/lang.array;
import ballerina/log;
import ballerina/mime;

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

    resource function get cities/[int district_id]() returns City[]|error {
        GetCitiesResponse|graphql:ClientError getCitiesResponse = globalDataClient->getCities(district_id);
        if (getCitiesResponse is GetCitiesResponse) {
            City[] citiesData = [];
            foreach var city in getCitiesResponse.cities {
                City|error cityData = city.cloneWithType(City);
                if (cityData is City) {
                    citiesData.push(cityData);
                } else {
                    log:printError("Error while processing Application record received", cityData);
                    return error("Error while processing Application record received: " + cityData.message() +
                        ":: Detail: " + cityData.detail().toString());
                }
            }

            return citiesData;

        } else {
            log:printError("Error while getting application", getCitiesResponse);
            return error("Error while getting application: " + getCitiesResponse.message() +
                ":: Detail: " + getCitiesResponse.detail().toString());
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

        Address? mailing_address = person?.mailing_address;
        City? mailing_address_city = mailing_address?.city;

        if (mailing_address is Address) {
            mailing_address.city = ();
        }

        person.mailing_address = ();

        UpdatePersonResponse|graphql:ClientError updatePersonResponse = globalDataClient->updatePerson(person,mailing_address,mailing_address_city);
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

    resource function post add_person(@http:Payload Person person) returns Person|ErrorDetail|error {

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
                return {
                    "message": person_record.message().toString(),
                    "errorCode": "500"
                };
            }
        } else {
            log:printError("Error while creating application", addPersonResponse);
            return {
                "message": addPersonResponse.message().toString(),
                "errorCode": "500"
            };
        }
    }
    resource function post upload_document(http:Request req) returns UserDocument|ErrorDetail|error {

        UserDocument document = {};
        UserDocument document_details = {};
        int document_row_id = 0;
        string document_type = "";

        if (req.getContentType().startsWith("multipart/form-data")) {

            mime:Entity[] bodyParts = check req.getBodyParts();
            string base64EncodedStringDocument = "";

            foreach var part in bodyParts {
                mime:ContentDisposition contentDisposition = part.getContentDisposition();

                if (contentDisposition.name == "document_details") {

                    json document_details_in_json = check part.getJson();
                    document_details = check document_details_in_json.cloneWithType(UserDocument);
                    document_row_id = document_details?.id ?: 0;
                    document_type = document_details?.document_type ?: "";

                } else if (contentDisposition.name == "document") {

                    stream<byte[], io:Error?>|mime:ParserError str = part.getByteStream();

                    if str is stream<byte[], io:Error?> {

                        byte[] allBytes = []; // Initialize an empty byte array

                        // Iterate through the stream and collect all chunks
                        error? e = str.forEach(function(byte[] chunk) {
                            array:push(allBytes, ...chunk); // Efficiently append all bytes from chunk
                        });

                        byte[] base64EncodedDocument = <byte[]>(check mime:base64Encode(allBytes));
                        base64EncodedStringDocument = check string:fromBytes(base64EncodedDocument);

                    }
                }

            }

            document = {
                id: document_row_id,
                document_type: document_type,
                document: base64EncodedStringDocument
            };

        }

        UploadDocumentResponse|graphql:ClientError uploadDocumentResponse = globalDataClient->uploadDocument(document);
        if (uploadDocumentResponse is UploadDocumentResponse) {
            UserDocument|error document_record = uploadDocumentResponse.upload_document.cloneWithType(UserDocument);
            if (document_record is UserDocument) {
                return document_record;
            } else {
                log:printError("Error while processing Application record received", document_record);
                return {
                    "message": document_record.message().toString(),
                    "errorCode": "500"
                };
            }
        } else {
            log:printError("Error while creating application", uploadDocumentResponse);
            return {
                "message": uploadDocumentResponse.message().toString(),
                "errorCode": "500"
            };
        }
    }

    resource function get document_list/[int id]() returns UserDocument[]|error {
        GetAllDocumentsResponse|graphql:ClientError getDocumentsResponse = globalDataClient->getAllDocuments(id);
        if (getDocumentsResponse is GetAllDocumentsResponse) {
            UserDocument[] document_datas = [];
            foreach var document_data in getDocumentsResponse.document_list {
                UserDocument|error document_data_record = document_data.cloneWithType(UserDocument);
                if (document_data_record is UserDocument) {
                    document_datas.push(document_data_record);
                } else {
                    log:printError("Error while processing Application record received", document_data_record);
                    return error("Error while processing Application record received: " + document_data_record.message() +
                        ":: Detail: " + document_data_record.detail().toString());
                }
            }

            return document_datas;

        } else {
            log:printError("Error while getting application", getDocumentsResponse);
            return error("Error while getting application: " + getDocumentsResponse.message() +
                ":: Detail: " + getDocumentsResponse.detail().toString());
        }
    }


    // resource function post add_person(http:Request req) returns Person|error {
    //     UserDocumentList[] documents = [];
    //     Person person = {};
    //     Address? mailing_address = {};
    //     City? mailing_address_city = {};

    //     if (req.getContentType().startsWith("multipart/form-data")) {
    //         mime:Entity[] bodyParts = check req.getBodyParts();

    //         foreach var part in bodyParts {
    //             mime:ContentDisposition contentDisposition = part.getContentDisposition();

    //             if (contentDisposition.name == "person") {
    //                 // Extract JSON string and convert to Person record
    //                 json personJson = check part.getJson();
    //                 person = check personJson.cloneWithType(Person);
    //                 mailing_address = person?.mailing_address;
    //                 mailing_address_city = mailing_address?.city;

    //                 if (mailing_address is Address) {
    //                     mailing_address.city = ();
    //                 }

    //                 person.mailing_address = ();

    //             } else if (contentDisposition.name == "documents") {

    //                 // Get the filename from Content-Disposition
    //                 string? documentName = contentDisposition.fileName;

    //                 stream<byte[], io:Error?>|mime:ParserError str = part.getByteStream();

    //                 //Extract file name without extension
    //                 string:RegExp r = re `\.`;
    //                 string[] split_document_name = r.split(documentName ?: "");

    //                 if str is stream<byte[], io:Error?> {

    //                     byte[] allBytes = []; // Initialize an empty byte array

    //                     // Iterate through the stream and collect all chunks
    //                     error? e = str.forEach(function(byte[] chunk) {
    //                          array:push(allBytes, ...chunk); // Efficiently append all bytes from chunk
    //                     });

    //                     byte[] base64EncodedDocument = <byte[]>(check mime:base64Encode(allBytes));
    //                     string base64EncodedStringDocument = check string:fromBytes(base64EncodedDocument);

    //                     UserDocumentList document = {
    //                         document_name: split_document_name[0],
    //                         document: base64EncodedStringDocument

    //                     };
    //                     //io:println(document);
    //                     documents.push(document);
    //                 }
    //             }

    //         }
    //     }
    //     InsertPersonResponse|graphql:ClientError addPersonResponse = globalDataClient->insertPerson(documents, person, mailing_address, mailing_address_city);
    //     if (addPersonResponse is InsertPersonResponse) {
    //         Person|error person_record = addPersonResponse.insert_person.cloneWithType(Person);
    //         if (person_record is Person) {
    //             return person_record;
    //         } else {
    //             log:printError("Error while processing Application record received", person_record);
    //             return error("Error while processing Application record received: " + person_record.message() +
    //                 ":: Detail: " + person_record.detail().toString());
    //         }
    //     } else {
    //         log:printError("Error while creating application", addPersonResponse);
    //         return error("Error while creating application: " + addPersonResponse.message() +
    //             ":: Detail: " + addPersonResponse.detail().toString());
    //     }
    // }
}
