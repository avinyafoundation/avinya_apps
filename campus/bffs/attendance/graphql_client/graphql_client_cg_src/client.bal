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
    remote isolated function getAvinyaTypes() returns GetAvinyaTypesResponse|graphql:ClientError {
        string query = string `query getAvinyaTypes {avinya_types {id active name global_type foundation_type focus level}}`;
        map<anydata> variables = {};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetAvinyaTypesResponse> check performDataBinding(graphqlResponse, GetAvinyaTypesResponse);
    }
    remote isolated function createAvinyaType(AvinyaType avinyaType) returns CreateAvinyaTypeResponse|graphql:ClientError {
        string query = string `mutation createAvinyaType($avinyaType:AvinyaType!) {add_avinya_type(avinya_type:$avinyaType) {id active name global_type foundation_type focus level}}`;
        map<anydata> variables = {"avinyaType": avinyaType};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <CreateAvinyaTypeResponse> check performDataBinding(graphqlResponse, CreateAvinyaTypeResponse);
    }
    remote isolated function updateAvinyaType(AvinyaType avinyaType) returns UpdateAvinyaTypeResponse|graphql:ClientError {
        string query = string `mutation updateAvinyaType($avinyaType:AvinyaType!) {update_avinya_type(avinya_type:$avinyaType) {id active name global_type foundation_type focus level}}`;
        map<anydata> variables = {"avinyaType": avinyaType};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <UpdateAvinyaTypeResponse> check performDataBinding(graphqlResponse, UpdateAvinyaTypeResponse);
    }
    remote isolated function getActivity(string name) returns GetActivityResponse|graphql:ClientError {
        string query = string `query getActivity($name:String!) {activity(name:$name) {id name description notes activity_instances {id name description notes start_time end_time daily_sequence weekly_sequence monthly_sequence} child_activities {id name description notes activity_instances {id name description notes start_time end_time daily_sequence weekly_sequence monthly_sequence} activity_sequence_plan {id sequence_number timeslot_number organization {id name {name_en}} person {preferred_name}}}}}`;
        map<anydata> variables = {"name": name};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetActivityResponse> check performDataBinding(graphqlResponse, GetActivityResponse);
    }
    remote isolated function addActivityAttendance(ActivityParticipantAttendance attendance) returns AddActivityAttendanceResponse|graphql:ClientError {
        string query = string `mutation addActivityAttendance($attendance:ActivityParticipantAttendance!) {add_attendance(attendance:$attendance) {id activity_instance_id sign_in_time sign_out_time created}}`;
        map<anydata> variables = {"attendance": attendance};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <AddActivityAttendanceResponse> check performDataBinding(graphqlResponse, AddActivityAttendanceResponse);
    }
}
