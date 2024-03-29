import ballerina/graphql;
import ballerina/log;

public isolated client class GraphqlClient {
    final graphql:Client graphqlClient;
    public isolated function init(string serviceUrl, ConnectionConfig config = {}) returns graphql:ClientError? {
        graphql:ClientConfiguration graphqlClientConfig = {auth: config.oauth2ClientCredentialsGrantConfig, timeout: config.timeout, forwarded: config.forwarded, poolConfig: config.poolConfig, compression: config.compression, circuitBreaker: config.circuitBreaker, retryConfig: config.retryConfig, validation: config.validation};
        do {
            if config.http1Settings is ClientHttp1Settings {
                ClientHttp1Settings settings = check config.http1Settings.ensureType(ClientHttp1Settings);
                graphqlClientConfig.http1Settings = {...settings};
            }
            if config.cache is graphql:CacheConfig {
                graphqlClientConfig.cache = check config.cache.ensureType(graphql:CacheConfig);
            }
            if config.responseLimits is graphql:ResponseLimitConfigs {
                graphqlClientConfig.responseLimits = check config.responseLimits.ensureType(graphql:ResponseLimitConfigs);
            }
            if config.secureSocket is graphql:ClientSecureSocket {
                graphqlClientConfig.secureSocket = check config.secureSocket.ensureType(graphql:ClientSecureSocket);
            }
            if config.proxy is graphql:ProxyConfig {
                graphqlClientConfig.proxy = check config.proxy.ensureType(graphql:ProxyConfig);
            }
        } on fail var e {
            return <graphql:ClientError>error("GraphQL Client Error", e, body = ());
        }
        graphql:Client clientEp = check new (serviceUrl, graphqlClientConfig);
        self.graphqlClient = clientEp;
    }
    remote isolated function createStudentApplicant(Person person) returns CreateStudentApplicantResponse|graphql:ClientError {
        string query = string `mutation createStudentApplicant($person: Person!)
  {add_student_applicant(person:$person){
    preferred_name,
    full_name,
    sex,
    organization_id,
    date_of_birth,
    phone,
    email,
    avinya_type_id,
    jwt_sub_id,
    jwt_email,
    street_address,
    id_no,
    branch_code,
    id
  }}`;
        map<anydata> variables = {"person": person};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <CreateStudentApplicantResponse> check performDataBinding(graphqlResponse, CreateStudentApplicantResponse);
    }
    remote isolated function createStudentApplicantConsent(ApplicantConsent consent) returns CreateStudentApplicantConsentResponse|graphql:ClientError {
        string query = string `mutation createStudentApplicantConsent($consent:ApplicantConsent!) {add_student_applicant_consent(applicantConsent:$consent) {organization_id avinya_type_id person_id application_id name date_of_birth done_ol ol_year done_al al_year al_stream distance_to_school phone email information_correct_consent agree_terms_consent}}`;
        map<anydata> variables = {"consent": consent};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <CreateStudentApplicantConsentResponse> check performDataBinding(graphqlResponse, CreateStudentApplicantConsentResponse);
    }
    remote isolated function getOrganizationVacancies(string name) returns GetOrganizationVacanciesResponse|graphql:ClientError {
        string query = string `query getOrganizationVacancies($name:String!) {organization_structure(name:$name) {organizations {name {name_en} address {street_address} avinya_type {name active global_type foundation_type focus level} phone child_organizations {name {name_en} vacancies {name description head_count avinya_type {name active global_type foundation_type focus level} evaluation_criteria {prompt description difficulty evaluation_type rating_out_of answer_options {answer}}}} parent_organizations {name {name_en}} vacancies {name description head_count}}}}`;
        map<anydata> variables = {"name": name};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetOrganizationVacanciesResponse> check performDataBinding(graphqlResponse, GetOrganizationVacanciesResponse);
    }
    remote isolated function createProspect(Prospect prospect) returns CreateProspectResponse|graphql:ClientError {
        string query = string `mutation createProspect($prospect:Prospect!) {add_prospect(prospect:$prospect) {name phone email receive_information_consent agree_terms_consent created}}`;
        map<anydata> variables = {"prospect": prospect};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <CreateProspectResponse> check performDataBinding(graphqlResponse, CreateProspectResponse);
    }
    remote isolated function createStudentApplication(Application application) returns CreateStudentApplicationResponse|graphql:ClientError {
        string query = string `mutation createStudentApplication($application:Application!) {add_application(application:$application) {id statuses {status}}}`;
        map<anydata> variables = {"application": application};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <CreateStudentApplicationResponse> check performDataBinding(graphqlResponse, CreateStudentApplicationResponse);
    }
    remote isolated function getApplication(int person_id) returns GetApplicationResponse|graphql:ClientError {
        string query = string `query getApplication($person_id:Int!) {application(person_id:$person_id) {application_date statuses {status updated}}}`;
        map<anydata> variables = {"person_id": person_id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetApplicationResponse> check performDataBinding(graphqlResponse, GetApplicationResponse);
    }

    remote isolated function getActiveActivityInstance() returns GetActiveActivityInstanceResponse|graphql:ClientError {
        string query = string `query getActiveActivityInstance() {application() {id activity_id name place_id organization_id daily_sequence weekly_sequence monthly_sequence description notes start_time end_time created updated}}`;
        json graphqlResponse = check self.graphqlClient->executeWithType(query);
        return <GetActiveActivityInstanceResponse> check performDataBinding(graphqlResponse, GetActiveActivityInstanceResponse);
    }
    remote isolated function getStudentApplicant(string jwt_sub_id) returns GetStudentApplicantResponse|graphql:ClientError {
        string query = string `query getStudentApplicant($jwt_sub_id:String!) {student_applicant(jwt_sub_id:$jwt_sub_id) {asgardeo_id full_name preferred_name email phone jwt_sub_id jwt_email}}`;
        map<anydata> variables = {"jwt_sub_id": jwt_sub_id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetStudentApplicantResponse> check performDataBinding(graphqlResponse, GetStudentApplicantResponse);
    }

    remote isolated function createEvaluations(Evaluation[] evaluations) returns json|graphql:ClientError {
        string query = string `mutation createEvaluations($evaluations: [Evaluation!]!)
                                {
                                    add_evaluations(evaluations:$evaluations) 
                                        
                                }`;
        map<anydata> variables = {"evaluations": evaluations};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        log:printInfo("Response: " + graphqlResponse.toString());
        return graphqlResponse;
    }
}
