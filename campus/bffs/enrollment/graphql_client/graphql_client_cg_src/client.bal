import ballerina/graphql;

public isolated client class GraphqlClient {
    final graphql:Client graphqlClient;
    public isolated function init(string serviceUrl, ConnectionConfig config = {}) returns graphql:ClientError? {
        graphql:ClientConfiguration graphqlClientConfig = {timeout: config.timeout, forwarded: config.forwarded, poolConfig: config.poolConfig, compression: config.compression, circuitBreaker: config.circuitBreaker, retryConfig: config.retryConfig, validation: config.validation};
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
    remote isolated function getPersons(int organization_id, int avinya_type_id) returns GetPersonsResponse|graphql:ClientError {
        string query = string `query getPersons($organization_id:Int!,$avinya_type_id:Int!) {persons(organization_id:$organization_id,avinya_type_id:$avinya_type_id) {id preferred_name full_name date_of_birth sex asgardeo_id jwt_sub_id created updated jwt_email permanent_address {city {id name {name_en name_si name_ta}} street_address phone id} mailing_address {city {id name {name_en name_si name_ta}} street_address phone id} phone organization {id description notes address {id} avinya_type {id name} name {name_en} parent_organizations {id name {name_en}}} avinya_type_id notes nic_no passport_no id_no email street_address digital_id avinya_phone bank_name bank_account_number bank_account_name academy_org_id bank_branch created_by updated_by current_job}}`;
        map<anydata> variables = {"organization_id": organization_id, "avinya_type_id": avinya_type_id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetPersonsResponse> check performDataBinding(graphqlResponse, GetPersonsResponse);
    }
    remote isolated function getPersonById(int id) returns GetPersonByIdResponse|graphql:ClientError {
        string query = string `query getPersonById($id:Int!) {person_by_id(id:$id) {id preferred_name full_name date_of_birth sex asgardeo_id jwt_sub_id created updated jwt_email mailing_address {city {id name {name_en name_si name_ta} district {id name {name_en}}} street_address phone id} phone organization {id description notes address {id} avinya_type {id name} name {name_en} parent_organizations {id name {name_en}}} avinya_type_id notes nic_no passport_no id_no email street_address digital_id avinya_phone bank_name bank_account_number bank_account_name academy_org_id bank_branch created_by updated_by current_job document_list {document document_type}}}`;
        map<anydata> variables = {"id": id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetPersonByIdResponse> check performDataBinding(graphqlResponse, GetPersonByIdResponse);
    }
    remote isolated function updatePerson(Person person, City? permanent_address_city = (), Address? mailing_address = (), Address? permanent_address = (), City? mailing_address_city = ()) returns UpdatePersonResponse|graphql:ClientError {
        string query = string `mutation updatePerson($person:Person!,$permanent_address:Address,$permanent_address_city:City,$mailing_address:Address,$mailing_address_city:City) {update_person(person:$person,permanent_address:$permanent_address,permanent_address_city:$permanent_address_city,mailing_address:$mailing_address,mailing_address_city:$mailing_address_city) {id preferred_name full_name date_of_birth sex asgardeo_id jwt_sub_id created updated jwt_email permanent_address {city {id name {name_en name_si name_ta}} street_address phone id} mailing_address {city {id name {name_en name_si name_ta}} street_address phone id} phone organization {id description notes address {id} avinya_type {id name} name {name_en} parent_organizations {id name {name_en}}} avinya_type_id notes nic_no passport_no id_no email street_address digital_id avinya_phone bank_name bank_account_number bank_account_name academy_org_id bank_branch created_by updated_by current_job}}`;
        map<anydata> variables = {"permanent_address_city": permanent_address_city, "mailing_address": mailing_address, "person": person, "permanent_address": permanent_address, "mailing_address_city": mailing_address_city};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <UpdatePersonResponse> check performDataBinding(graphqlResponse, UpdatePersonResponse);
    }
    remote isolated function getDistricts() returns GetDistrictsResponse|graphql:ClientError {
        string query = string `query getDistricts {districts {id province {id name {name_en}} name {name_en}}}`;
        map<anydata> variables = {};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetDistrictsResponse> check performDataBinding(graphqlResponse, GetDistrictsResponse);
    }
    remote isolated function getCities(int district_id) returns GetCitiesResponse|graphql:ClientError {
        string query = string `query getCities($district_id:Int!) {cities(district_id:$district_id) {id name {name_en}}}`;
        map<anydata> variables = {"district_id": district_id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetCitiesResponse> check performDataBinding(graphqlResponse, GetCitiesResponse);
    }
    remote isolated function getAvinyaTypes() returns GetAvinyaTypesResponse|graphql:ClientError {
        string query = string `query getAvinyaTypes {avinya_types {id active name global_type foundation_type focus level}}`;
        map<anydata> variables = {};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetAvinyaTypesResponse> check performDataBinding(graphqlResponse, GetAvinyaTypesResponse);
    }
    remote isolated function getAllOrganizations() returns GetAllOrganizationsResponse|graphql:ClientError {
        string query = string `query getAllOrganizations {all_organizations {id name {name_en} address {id street_address} avinya_type {id name} description phone notes}}`;
        map<anydata> variables = {};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetAllOrganizationsResponse> check performDataBinding(graphqlResponse, GetAllOrganizationsResponse);
    }
    remote isolated function insertPerson(Person person, Address? mailing_address = (), City? mailing_address_city = ()) returns InsertPersonResponse|graphql:ClientError {
        string query = string `mutation insertPerson($person:Person!,$mailing_address:Address,$mailing_address_city:City) {insert_person(person:$person,mailing_address:$mailing_address,mailing_address_city:$mailing_address_city) {id preferred_name full_name date_of_birth sex asgardeo_id jwt_sub_id created updated jwt_email permanent_address {city {id name {name_en name_si name_ta}} street_address phone id} mailing_address {city {id name {name_en name_si name_ta}} street_address phone id} phone organization {id description notes address {id} avinya_type {id name} name {name_en} parent_organizations {id name {name_en}}} avinya_type_id notes nic_no passport_no id_no email street_address digital_id avinya_phone bank_name bank_account_number bank_account_name academy_org_id bank_branch created_by updated_by current_job documents_id}}`;
        map<anydata> variables = {"mailing_address": mailing_address, "person": person, "mailing_address_city": mailing_address_city};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <InsertPersonResponse> check performDataBinding(graphqlResponse, InsertPersonResponse);
    }
    remote isolated function uploadDocument(UserDocument user_document) returns UploadDocumentResponse|graphql:ClientError {
        string query = string `mutation uploadDocument($user_document:UserDocument!) {upload_document(user_document:$user_document) {id folder_id nic_front_id nic_back_id birth_certificate_front_id birth_certificate_back_id ol_certificate_id al_certificate_id additional_certificate_01_id additional_certificate_02_id additional_certificate_03_id additional_certificate_04_id additional_certificate_05_id}}`;
        map<anydata> variables = {"user_document": user_document};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <UploadDocumentResponse> check performDataBinding(graphqlResponse, UploadDocumentResponse);
    }
}
