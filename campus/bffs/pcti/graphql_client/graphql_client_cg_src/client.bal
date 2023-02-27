import ballerina/graphql;

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
    remote isolated function getPctiInstanceNotes(int pcti_instance_id) returns GetPctiInstanceNotesResponse|graphql:ClientError {
        string query = string `query getPctiInstanceNotes($pcti_instance_id:Int!) {pcti_instance_notes(pcti_instance_id:$pcti_instance_id) {id evaluatee_id evaluator_id evaluation_criteria_id updated notes grade child_evaluations {id evaluatee_id evaluator_id evaluation_criteria_id updated notes grade} parent_evaluations {id evaluatee_id evaluator_id evaluation_criteria_id updated notes grade}}}`;
        map<anydata> variables = {"pcti_instance_id": pcti_instance_id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetPctiInstanceNotesResponse> check performDataBinding(graphqlResponse, GetPctiInstanceNotesResponse);
    }
    remote isolated function getPctiNotes(int pcti_activity_id) returns GetPctiNotesResponse|graphql:ClientError {
        string query = string `query getPctiNotes($pcti_activity_id:Int!) {pcti_notes(pcti_activity_id:$pcti_activity_id) {id evaluatee_id evaluator_id evaluation_criteria_id updated notes grade child_evaluations {id evaluatee_id evaluator_id evaluation_criteria_id updated notes grade} parent_evaluations {id evaluatee_id evaluator_id evaluation_criteria_id updated notes grade}}}`;
        map<anydata> variables = {"pcti_activity_id": pcti_activity_id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetPctiNotesResponse> check performDataBinding(graphqlResponse, GetPctiNotesResponse);
    }
    remote isolated function getActivity(string? name = (), int? id = ()) returns GetActivityResponse|graphql:ClientError {
        string query = string `query getActivity($name:String,$id:Int) {activity(name:$name,id:$id) {id name description avinya_type {id active global_type name foundation_type focus level description} notes child_activities {id name description avinya_type {id active global_type name foundation_type focus level description} notes activity_instances {id name description notes start_time end_time daily_sequence weekly_sequence monthly_sequence} activity_sequence_plan {id sequence_number timeslot_number organization {id name {name_en}} person {preferred_name}}} parent_activities {id name description avinya_type {id active global_type name foundation_type focus level description} notes activity_instances {id name description notes start_time end_time daily_sequence weekly_sequence monthly_sequence} activity_sequence_plan {id sequence_number timeslot_number organization {id name {name_en}} person {preferred_name}}} activity_sequence_plan {id sequence_number timeslot_number organization {id name {name_en}} person {preferred_name}} activity_instances {id name description notes start_time end_time daily_sequence weekly_sequence monthly_sequence}}}`;
        map<anydata> variables = {"name": name, "id": id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetActivityResponse> check performDataBinding(graphqlResponse, GetActivityResponse);
    }
    remote isolated function addActivity(Activity activity) returns AddActivityResponse|graphql:ClientError {
        string query = string `mutation addActivity($activity:Activity!) {add_activity(activity:$activity) {id name description avinya_type {id active global_type name foundation_type focus level description} notes child_activities {id name description avinya_type {id active global_type name foundation_type focus level description} notes activity_instances {id name description notes start_time end_time daily_sequence weekly_sequence monthly_sequence} activity_sequence_plan {id sequence_number timeslot_number organization {id name {name_en}} person {preferred_name}}} parent_activities {id name description avinya_type {id active global_type name foundation_type focus level description} notes activity_instances {id name description notes start_time end_time daily_sequence weekly_sequence monthly_sequence} activity_sequence_plan {id sequence_number timeslot_number organization {id name {name_en}} person {preferred_name}}} activity_sequence_plan {id sequence_number timeslot_number organization {id name {name_en}} person {preferred_name}} activity_instances {id name description notes start_time end_time daily_sequence weekly_sequence monthly_sequence}}}`;
        map<anydata> variables = {"activity": activity};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <AddActivityResponse> check performDataBinding(graphqlResponse, AddActivityResponse);
    }
    remote isolated function addActivityInstance(ActivityInstance activityInstance) returns AddActivityInstanceResponse|graphql:ClientError {
        string query = string `mutation addActivityInstance($activityInstance:ActivityInstance!) {add_activity_instance(activityInstance:$activityInstance) {id name description activity_id notes daily_sequence weekly_sequence monthly_sequence start_time end_time created updated activity_participants {id activity_instance_id person {preferred_name} organization {id name {name_en}} start_date end_date role notes created updated} activity_participant_attendances {id activity_instance_id person {preferred_name} sign_in_time sign_out_time created updated} evaluations {id evaluatee_id evaluator_id evaluation_criteria_id updated notes grade child_evaluations {id evaluatee_id evaluator_id evaluation_criteria_id updated notes grade} parent_evaluations {id evaluatee_id evaluator_id evaluation_criteria_id updated notes grade}}}}`;
        map<anydata> variables = {"activityInstance": activityInstance};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <AddActivityInstanceResponse> check performDataBinding(graphqlResponse, AddActivityInstanceResponse);
    }
    remote isolated function addPctiNotes(string notes, int pcti_instance_id, int evaluator_id) returns AddPctiNotesResponse|graphql:ClientError {
        string query = string `mutation addPctiNotes($pcti_instance_id:Int!,$notes:String!,$evaluator_id:Int!) {add_pcti_notes(pcti_instance_id:$pcti_instance_id,notes:$notes,evaluator_id:$evaluator_id) {id evaluatee_id evaluator_id evaluation_criteria_id updated notes grade child_evaluations {id evaluatee_id evaluator_id evaluation_criteria_id updated notes grade} parent_evaluations {id evaluatee_id evaluator_id evaluation_criteria_id updated notes grade}}}`;
        map<anydata> variables = {"notes": notes, "pcti_instance_id": pcti_instance_id, "evaluator_id": evaluator_id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <AddPctiNotesResponse> check performDataBinding(graphqlResponse, AddPctiNotesResponse);
    }
}
