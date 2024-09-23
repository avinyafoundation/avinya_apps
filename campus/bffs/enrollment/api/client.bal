import ballerina/graphql;

public isolated client class GraphqlClient {
    final graphql:Client graphqlClient;
    public isolated function init(string serviceUrl, ConnectionConfig config = {}) returns graphql:ClientError? {
        graphql:ClientConfiguration graphqlClientConfig = {auth: config.oauth2ClientCredentialsGrantConfig,timeout: config.timeout, forwarded: config.forwarded, poolConfig: config.poolConfig, compression: config.compression, circuitBreaker: config.circuitBreaker, retryConfig: config.retryConfig, validation: config.validation};
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
        string query = string `query getPersons($organization_id:Int!,$avinya_type_id:Int!) {persons(organization_id:$organization_id,avinya_type_id:$avinya_type_id) {id preferred_name full_name date_of_birth sex asgardeo_id jwt_sub_id created updated jwt_email permanent_address {city {id name {name_en name_si name_ta}} street_address phone id} mailing_address {city {id name {name_en name_si name_ta}} street_address phone id} phone organization {id description notes address {id} avinya_type {id name} name {name_en}} avinya_type {id name} notes nic_no passport_no id_no email street_address digital_id avinya_phone bank_name bank_account_number bank_account_name academy_org_id bank_branch}}`;
        map<anydata> variables = {"organization_id": organization_id, "avinya_type_id": avinya_type_id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetPersonsResponse>check performDataBinding(graphqlResponse, GetPersonsResponse);
    }

}
