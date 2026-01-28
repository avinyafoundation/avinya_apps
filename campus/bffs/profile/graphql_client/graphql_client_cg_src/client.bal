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
    remote isolated function getPerson(string id) returns GetPersonResponse|graphql:ClientError {
        string query = string `query getPerson($id:String!) {person_by_digital_id(id:$id) {id preferred_name full_name date_of_birth sex asgardeo_id jwt_sub_id created updated jwt_email permanent_address {city {id name {name_en name_si name_ta}} street_address phone id} mailing_address {city {id name {name_en name_si name_ta}} street_address phone id} phone organization {id description notes address {id} avinya_type {id} phone name {name_en name_si name_ta} child_organizations {id name {name_en} description child_organizations {id name {name_en} description child_organizations {id name {name_en} description people {id digital_id}}}} parent_organizations {id parent_organizations {id}}} avinya_type {id active global_type name foundation_type focus level description} avinya_type_id notes nic_no passport_no id_no email child_students {id preferred_name full_name date_of_birth sex asgardeo_id jwt_sub_id jwt_email permanent_address {id} mailing_address {id} phone organization {id} avinya_type {id} avinya_type_id notes nic_no passport_no id_no email child_students {id} parent_students {id} street_address digital_id avinya_phone bank_name bank_account_number bank_account_name academy_org_id} parent_students {id preferred_name full_name date_of_birth sex asgardeo_id jwt_sub_id jwt_email permanent_address {id} mailing_address {id} phone organization {id} avinya_type {id} avinya_type_id notes nic_no passport_no id_no email child_students {id} parent_students {id} street_address digital_id avinya_phone bank_name bank_account_number bank_account_name academy_org_id} street_address digital_id avinya_phone bank_name bank_account_number bank_account_name academy_org_id current_job documents_id alumni_id is_graduated profile_picture_folder_id}}`;
        map<anydata> variables = {"id": id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetPersonResponse> check performDataBinding(graphqlResponse, GetPersonResponse);
    }
    remote isolated function getOrganization(int id) returns GetOrganizationResponse|graphql:ClientError {
        string query = string `query getOrganization($id:Int!) {organization(id:$id) {id name {name_en} description child_organizations {id name {name_en} description} parent_organizations {id name {name_en} description} people {id preferred_name digital_id nic_no}}}`;
        map<anydata> variables = {"id": id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetOrganizationResponse> check performDataBinding(graphqlResponse, GetOrganizationResponse);
    }
    remote isolated function getStudentByParentOrg(int? batch_id = (), int? parent_organization_id = ()) returns GetStudentByParentOrgResponse|graphql:ClientError {
        string query = string `query getStudentByParentOrg($parent_organization_id:Int,$batch_id:Int) {student_list_by_parent(parent_organization_id:$parent_organization_id,batch_id:$batch_id) {id preferred_name full_name date_of_birth sex asgardeo_id jwt_sub_id created updated jwt_email phone avinya_type_id notes nic_no passport_no id_no email street_address digital_id avinya_phone bank_name bank_account_number bank_account_name bank_branch academy_org_id organization {id name {name_en} description}}}`;
        map<anydata> variables = {"batch_id": batch_id, "parent_organization_id": parent_organization_id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetStudentByParentOrgResponse> check performDataBinding(graphqlResponse, GetStudentByParentOrgResponse);
    }
    remote isolated function validatePin(string pin) returns ValidatePinResponse|graphql:ClientError {
        string query = string `query validatePin($pin:String!) {validatePin(pin:$pin) {id preferred_name}}`;
        map<anydata> variables = {"pin": pin};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <ValidatePinResponse> check performDataBinding(graphqlResponse, ValidatePinResponse);
    }
}
