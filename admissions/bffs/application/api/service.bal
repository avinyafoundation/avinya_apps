import ballerina/http;
import ballerina/log;
import ballerina/graphql;

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
# bound to port `9090`.
service / on new http:Listener(9090) {

    # Creates a student applicant Person record
    # + person - the input Person record
    # + return - Student record with persisted data
    resource function post student_applicant(@http:Payload Person person) returns Person|error {
        CreateStudentApplicantResponse|graphql:ClientError createStudentApplicantResponse = globalDataClient->createStudentApplicant(person);

        if(createStudentApplicantResponse is CreateStudentApplicantResponse) {
            Person|error person_record = createStudentApplicantResponse.add_student_applicant.cloneWithType(Person);
            if(person_record is Person) {
                return person_record;
            } else {
                log:printError("Error while processing Prospect record received", person_record);
                return error("Error while processing Prospect record received: " + person_record.message() + 
                    ":: Detail: " + person_record.detail().toString());
            }
        } else {
            log:printError("Error while creating prospect", createStudentApplicantResponse);
            return error("Error while creating prospect: " + createStudentApplicantResponse.message() + 
                ":: Detail: " + createStudentApplicantResponse.detail().toString());
        }
    }

    # Creates an ApplicantConsent record
    # Persists the consent record for the given applicant
    # + applicantConsent - the input ApplicantConsent record
    # + return - ApplicantConsentData record with persisted data
    resource function post applicant_consent(@http:Payload ApplicantConsent applicantConsent) returns CreateStudentApplicantConsentResponse|error {
        CreateStudentApplicantConsentResponse|graphql:ClientError createStudentApplicantConsentResponse = globalDataClient->createStudentApplicantConsent(applicantConsent);
        return createStudentApplicantConsentResponse;
    }

    # Creates an Prospect record
    # Persists the contact and consent information for the given prospect
    # + prospect - the input Prospect record
    # + return - Prospect record returned from create operation with persisted data
    resource function post prospect(@http:Payload Prospect prospect) returns Prospect|error {
        CreateProspectResponse|graphql:ClientError createProspectResponse = globalDataClient->createProspect(prospect);
        if(createProspectResponse is CreateProspectResponse) {
            Prospect|error prospect_record = createProspectResponse.add_prospect.cloneWithType(Prospect);
            if(prospect_record is Prospect) {
                return prospect_record;
            } else {
                log:printError("Error while processing Prospect record received", prospect_record);
                return error("Error while processing Prospect record received: " + prospect_record.message() + 
                    ":: Detail: " + prospect_record.detail().toString());
            }
        } else {
            log:printError("Error while creating prospect", createProspectResponse);
            return error("Error while creating prospect: " + createProspectResponse.message() + 
                ":: Detail: " + createProspectResponse.detail().toString());
        }
    }

    resource function post application (@http:Payload Application application) returns Application|error {
        CreateStudentApplicationResponse|graphql:ClientError createApplicationResponse = globalDataClient->createStudentApplication(application);
        if(createApplicationResponse is CreateStudentApplicationResponse) {
            Application|error application_record = createApplicationResponse.add_application.cloneWithType(Application);
            if(application_record is Application) {
                return application_record;
            } else {
                log:printError("Error while processing Application record received", application_record);
                return error("Error while processing Application record received: " + application_record.message() + 
                    ":: Detail: " + application_record.detail().toString());
            }
        } else {
            log:printError("Error while creating application", createApplicationResponse);
            return error("Error while creating application: " + createApplicationResponse.message() + 
                ":: Detail: " + createApplicationResponse.detail().toString());
        }
    }

    // resource function post address (@http:Payload Address address) returns Address|error {
    //     CreateAddressResponse|graphql:ClientError createAddressResponse = globalDataClient->createAddress(address);
    //     if(createAddressResponse is CreateAddressResponse) {
    //         Address|error address_record = createAddressResponse.add_address.cloneWithType(Address);
    //         if(address_record is Address) {
    //             return address_record;
    //         } else {
    //             log:printError("Error while processing Application record received", address_record);
    //             return error("Error while processing Application record received: " + address_record.message() + 
    //                 ":: Detail: " + address_record.detail().toString());
    //         }
    //     } else {
    //         log:printError("Error while creating application", createAddressResponse);
    //         return error("Error while creating application: " + createAddressResponse.message() + 
    //             ":: Detail: " + createAddressResponse.detail().toString());
    //     }
    // }

    resource function post evaluations (@http:Payload Evaluation[] evaluations) returns json|error {
        json|graphql:ClientError createEvaluationResponse = globalDataClient->createEvaluations(evaluations);
        if(createEvaluationResponse is json) {
            log:printInfo("Evaluations created successfully: " + createEvaluationResponse.toString());
            return createEvaluationResponse;
            // json|error evaluation_record = createEvaluationResponse.add_application_evaluation.cloneWithType(json);
            // if(evaluation_record is json) {
            //     return evaluation_record;
            // } else {
            //     log:printError("Error while processing Evaluation record received", evaluation_record);
            //     return error("Error while processing Evaluation record received: " + evaluation_record.message() + 
            //         ":: Detail: " + evaluation_record.detail().toString());
            // }
        } else {
            log:printError("Error while creating evaluation", createEvaluationResponse);
            return error("Error while creating evaluation: " + createEvaluationResponse.message() + 
                ":: Detail: " + createEvaluationResponse.detail().toString());
        }
        
    }

    # Get application details for a given person 
    # + person_id - the ID of the person who submitted the application 
    # + return - application details for the given person
    resource function get application/[int person_id]() returns Application|error {
        GetApplicationResponse|graphql:ClientError getApplicationResponse = globalDataClient->getApplication(person_id);
        if(getApplicationResponse is GetApplicationResponse) {
            Application|error application_record = getApplicationResponse.application.cloneWithType(Application);
            if(application_record is Application) {
                return application_record;
            } else {
                log:printError("Error while processing Application record received", application_record);
                return error("Error while processing Application record received: " + application_record.message() + 
                    ":: Detail: " + application_record.detail().toString());
            }
        } else {
            log:printError("Error while getting application", getApplicationResponse);
            return error("Error while getting application: " + getApplicationResponse.message() + 
                ":: Detail: " + getApplicationResponse.detail().toString());
        }
    }

    # Get vacancies for a named organization 
    # + org_name - the name of the organization to get vacancies for
    # + return - vacancies for the named organization including the sub-org hierarchy
    resource function get organization_vacancies/[string org_name]() returns GetOrganizationVacanciesResponse|error {
        GetOrganizationVacanciesResponse|graphql:ClientError getOrganizationVacanciesResponse = globalDataClient->getOrganizationVacancies(org_name);
        return getOrganizationVacanciesResponse;
    }

    # Get studnet vacancies for a named organization 
    # + org_name - the name of the organization to get vacancies for
    # + return - Student vacancies for the named organization
    resource function get student_vacancies/[string org_name]() returns Vacancy[]|error {
        Vacancy[] vacancy_records = [];
        GetOrganizationVacanciesResponse|graphql:ClientError getOrganizationVacanciesResponse = globalDataClient->getOrganizationVacancies(org_name);
        
        if(getOrganizationVacanciesResponse is GetOrganizationVacanciesResponse) {
             map<json> org_structure = check getOrganizationVacanciesResponse.toJson().ensureType();
             foreach var organizations in org_structure {
                json[]|error org_data = organizations.organizations.ensureType();
                
                if(org_data is json[]) {
                    foreach var data in org_data {
                        json[]|error child_orgs = data.child_organizations.ensureType();
                        if (child_orgs is json[]) {
                            foreach var child_org in child_orgs {
                            
                                json[]|error vacancies =  child_org.vacancies.ensureType();
                                if (vacancies is json[]) {
                                    foreach var vacancy in vacancies {
                                        Vacancy vacancy_record = check vacancy.cloneWithType(Vacancy);
                                        string global_type = vacancy_record?.avinya_type?.global_type?: "";
                                        string foundation_type = vacancy_record?.avinya_type?.foundation_type?: "";
                                        if(global_type.equalsIgnoreCaseAscii("applicant") && 
                                            foundation_type.equalsIgnoreCaseAscii("student")) {
                                            log:printInfo(vacancy_record?.head_count.toString() + "Student vacancies found");
                                            vacancy_records.push(vacancy_record);
                                            return vacancy_records; // assume only one student applicants vacancy block for current cycle of admissions 
                                        }
                                    }
                                } else {
                                    log:printError("Error vacancies: " + vacancies.toString());
                                }
                            }
                        } else {
                            log:printError("Error child_orgs: " + child_orgs.toString());
                        }
                    }
                } else {
                    log:printError("Error org_data: " + org_data.toString());
                }
             } 
        } else {
            return error("Error: student vacancies not found. " + getOrganizationVacanciesResponse.toString());
        }
        return error("Error: student vacancies not found.");
    }

    # Get person details for a given JWT subject(user) id. This method is to be used 
    # fo r mapping the logged in user to the person record in the system.
    # + jwt_sub_id - the subjecct (user) ID as per the JWT token 
    # + return - person details corresponding to the given JWT subject(user) id
    resource function get student_applicant/[string jwt_sub_id]() returns Person|error {
        GetStudentApplicantResponse|graphql:ClientError getStudentApplicantResponse = globalDataClient->getStudentApplicant(jwt_sub_id);
        if(getStudentApplicantResponse is GetStudentApplicantResponse) {
            Person|error person_record = getStudentApplicantResponse.student_applicant.cloneWithType(Person);
            if(person_record is Application) {
                return person_record;
            } else {
                log:printError("Error while processing Application record received", person_record);
                return error("Error while processing Application record received: " + person_record.message() + 
                    ":: Detail: " + person_record.detail().toString());
            }
        } else {
            log:printError("Error while getting application", getStudentApplicantResponse);
            return error("Error while getting application: " + getStudentApplicantResponse.message() + 
                ":: Detail: " + getStudentApplicantResponse.detail().toString());
        }
    }
    
}
