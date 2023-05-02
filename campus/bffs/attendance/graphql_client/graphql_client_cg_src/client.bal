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
    remote isolated function getActivityInstancesToday(int id) returns GetActivityInstancesTodayResponse|graphql:ClientError {
        string query = string `query getActivityInstancesToday($id:Int!) {activity_instances_today(activity_id:$id) {id activity_id name daily_sequence weekly_sequence monthly_sequence description notes start_time end_time created updated place {id} organization {id}}}`;
        map<anydata> variables = {"id": id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetActivityInstancesTodayResponse> check performDataBinding(graphqlResponse, GetActivityInstancesTodayResponse);
    }
    remote isolated function getClassAttendanceToday(int organization_id, int activity_id) returns GetClassAttendanceTodayResponse|graphql:ClientError {
        string query = string `query getClassAttendanceToday($organization_id:Int!,$activity_id:Int!) {class_attendance_today(organization_id:$organization_id,activity_id:$activity_id) {id person_id person {id} activity_instance_id sign_in_time sign_out_time in_marked_by out_marked_by}}`;
        map<anydata> variables = {"organization_id": organization_id, "activity_id": activity_id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetClassAttendanceTodayResponse> check performDataBinding(graphqlResponse, GetClassAttendanceTodayResponse);
    }
    remote isolated function getClassAttendanceReport(int result_limit, int organization_id, int activity_id) returns GetClassAttendanceReportResponse|graphql:ClientError {
        string query = string `query getClassAttendanceReport($organization_id:Int!,$activity_id:Int!,$result_limit:Int!) {class_attendance_report(organization_id:$organization_id,activity_id:$activity_id,result_limit:$result_limit) {id person {id} activity_instance_id sign_in_time sign_out_time in_marked_by out_marked_by}}`;
        map<anydata> variables = {"result_limit": result_limit, "organization_id": organization_id, "activity_id": activity_id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetClassAttendanceReportResponse> check performDataBinding(graphqlResponse, GetClassAttendanceReportResponse);
    }
    remote isolated function getPersonAttendanceReport(int result_limit, int activity_id, int person_id) returns GetPersonAttendanceReportResponse|graphql:ClientError {
        string query = string `query getPersonAttendanceReport($person_id:Int!,$activity_id:Int!,$result_limit:Int!) {person_attendance_report(person_id:$person_id,activity_id:$activity_id,result_limit:$result_limit) {id person {id} activity_instance_id sign_in_time sign_out_time in_marked_by out_marked_by}}`;
        map<anydata> variables = {"result_limit": result_limit, "activity_id": activity_id, "person_id": person_id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetPersonAttendanceReportResponse> check performDataBinding(graphqlResponse, GetPersonAttendanceReportResponse);
    }
    remote isolated function getPersonAttendanceToday(int activity_id, int person_id) returns GetPersonAttendanceTodayResponse|graphql:ClientError {
        string query = string `query getPersonAttendanceToday($person_id:Int!,$activity_id:Int!) {person_attendance_today(person_id:$person_id,activity_id:$activity_id) {id person {id} activity_instance_id sign_in_time sign_out_time in_marked_by out_marked_by}}`;
        map<anydata> variables = {"activity_id": activity_id, "person_id": person_id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetPersonAttendanceTodayResponse> check performDataBinding(graphqlResponse, GetPersonAttendanceTodayResponse);
    }
    remote isolated function getActivityEvaluations(int activity_id) returns GetActivityEvaluationsResponse|graphql:ClientError {
        string query = string `query getActivityEvaluations($activity_id:Int!) {activity_evaluations(activity_id:$activity_id) {id evaluatee_id evaluator_id evaluation_criteria_id response notes grade activity_instance_id updated}}`;
        map<anydata> variables = {"activity_id": activity_id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetActivityEvaluationsResponse> check performDataBinding(graphqlResponse, GetActivityEvaluationsResponse);
    }
    remote isolated function getActivityInstanceEvaluations(int activity_instance_id) returns GetActivityInstanceEvaluationsResponse|graphql:ClientError {
        string query = string `query getActivityInstanceEvaluations($activity_instance_id:Int!) {activity_instance_evaluations(activity_instance_id:$activity_instance_id) {id evaluatee_id evaluator_id evaluation_criteria_id response notes grade activity_instance_id updated}}`;
        map<anydata> variables = {"activity_instance_id": activity_instance_id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetActivityInstanceEvaluationsResponse> check performDataBinding(graphqlResponse, GetActivityInstanceEvaluationsResponse);
    }
}
