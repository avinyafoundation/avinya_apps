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
    
    remote isolated function saveOrganizationLocation(int organizationId, OrganizationLocation organizationLocation) returns SaveOrganizationLocationResponse|graphql:ClientError {
        string query = string `mutation saveOrganizationLocation($organizationId:Int!,$organizationLocation:OrganizationLocation!) {saveOrganizationLocation(organizationId:$organizationId,organizationLocation:$organizationLocation) {id organization_id location_name description}}`;
        map<anydata> variables = {"organizationId": organizationId, "organizationLocation": organizationLocation};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <SaveOrganizationLocationResponse> check performDataBinding(graphqlResponse, SaveOrganizationLocationResponse);
    }
    remote isolated function getLocationsByOrganization(int organizationId) returns GetLocationsByOrganizationResponse|graphql:ClientError {
        string query = string `query getLocationsByOrganization($organizationId:Int!) {locationsByOrganization(organizationId:$organizationId) {id organization_id location_name description}}`;
        map<anydata> variables = {"organizationId": organizationId};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetLocationsByOrganizationResponse> check performDataBinding(graphqlResponse, GetLocationsByOrganizationResponse);
    }
    remote isolated function getEmployeesByOrganization(int organization_id, int? avinya_type_id = ()) returns GetEmployeesByOrganizationResponse|graphql:ClientError {
        string query = string `query getEmployeesByOrganization($organization_id:Int!,$avinya_type_id:Int) {persons(organization_id:$organization_id,avinya_type_id:$avinya_type_id) {id preferred_name}}`;
        map<anydata> variables = {"organization_id": organization_id, "avinya_type_id": avinya_type_id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetEmployeesByOrganizationResponse> check performDataBinding(graphqlResponse, GetEmployeesByOrganizationResponse);
    }
    
}
