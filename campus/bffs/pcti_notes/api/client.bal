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
    remote isolated function getPerson(string? name = (), int? id = ()) returns GetPersonResponse|graphql:ClientError {
        string query = string `query getPerson($id:Int,$name:String) {person(id:$id,name:$name) {id preferred_name full_name date_of_birth sex asgardeo_id jwt_sub_id jwt_email permanent_address {id city {id name {name_en} district {id name {name_en} province {id name {name_en}}}}} mailing_address {id city {id name {name_en} district {id name {name_en} province {id name {name_en}}}}} phone organization {id name {name_en}} avinya_type {id active global_type name foundation_type focus level description} notes nic_no passport_no id_no email child_students {id preferred_name full_name date_of_birth} parent_students {id preferred_name full_name date_of_birth}}}`;
        map<anydata> variables = {"name": name, "id": id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetPersonResponse> check performDataBinding(graphqlResponse, GetPersonResponse);
    }
    remote isolated function getPctiActivityNotes(int pcti_activity_id) returns GetPctiActivityNotesResponse|graphql:ClientError {
        string query = string `query getPctiActivityNotes($pcti_activity_id:Int!) {pcti_activity_notes(pcti_activity_id:$pcti_activity_id) {id evaluatee_id evaluator_id evaluation_criteria_id updated notes grade child_evaluations {id evaluatee_id evaluator_id evaluation_criteria_id updated notes grade} parent_evaluations {id evaluatee_id evaluator_id evaluation_criteria_id updated notes grade}}}`;
        map<anydata> variables = {"pcti_activity_id": pcti_activity_id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetPctiActivityNotesResponse> check performDataBinding(graphqlResponse, GetPctiActivityNotesResponse);
    }
    remote isolated function getPctiActivity(string project_activity_name, string class_activity_name) returns GetPctiActivityResponse|graphql:ClientError {
        string query = string `query getPctiActivity($project_activity_name:String!,$class_activity_name:String!) {pcti_activity(project_activity_name:$project_activity_name,class_activity_name:$class_activity_name) {id name description avinya_type {id active global_type name foundation_type focus level description} notes child_activities {id name description avinya_type {id active global_type name foundation_type focus level description} notes activity_instances {id name description notes start_time end_time daily_sequence weekly_sequence monthly_sequence} activity_sequence_plan {id sequence_number timeslot_number organization {id name {name_en}} person {preferred_name}}} parent_activities {id name description avinya_type {id active global_type name foundation_type focus level description} notes activity_instances {id name description notes start_time end_time daily_sequence weekly_sequence monthly_sequence} activity_sequence_plan {id sequence_number timeslot_number organization {id name {name_en}} person {preferred_name}}} activity_sequence_plan {id sequence_number timeslot_number organization {id name {name_en}} person {preferred_name}} activity_instances {id name description notes start_time end_time daily_sequence weekly_sequence monthly_sequence}}}`;
        map<anydata> variables = {"project_activity_name": project_activity_name, "class_activity_name": class_activity_name};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetPctiActivityResponse> check performDataBinding(graphqlResponse, GetPctiActivityResponse);
    }
    remote isolated function getActivity(string? name = (), int? id = ()) returns GetActivityResponse|graphql:ClientError {
        string query = string `query getActivity($name:String,$id:Int) {activity(name:$name,id:$id) {id name description avinya_type {id active global_type name foundation_type focus level description} notes child_activities {id name description avinya_type {id active global_type name foundation_type focus level description} notes activity_instances {id name description notes start_time end_time daily_sequence weekly_sequence monthly_sequence} activity_sequence_plan {id sequence_number timeslot_number organization {id name {name_en}} person {preferred_name}}} parent_activities {id name description avinya_type {id active global_type name foundation_type focus level description} notes activity_instances {id name description notes start_time end_time daily_sequence weekly_sequence monthly_sequence} activity_sequence_plan {id sequence_number timeslot_number organization {id name {name_en}} person {preferred_name}}} activity_sequence_plan {id sequence_number timeslot_number organization {id name {name_en}} person {preferred_name}} activity_instances {id name description notes start_time end_time daily_sequence weekly_sequence monthly_sequence}}}`;
        map<anydata> variables = {"name": name, "id": id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetActivityResponse> check performDataBinding(graphqlResponse, GetActivityResponse);
    }
    remote isolated function getPctiParticipantActivities(int pcti_participant_id) returns GetPctiParticipantActivitiesResponse|graphql:ClientError {
        string query = string `query getPctiParticipantActivities($pcti_participant_id:Int!) {pcti_participant_activities(participant_id:$pcti_participant_id) {id name description avinya_type {id active global_type name foundation_type focus level description} notes child_activities {id name description avinya_type {id active global_type name foundation_type focus level description} notes activity_instances {id name description notes start_time end_time daily_sequence weekly_sequence monthly_sequence} activity_sequence_plan {id sequence_number timeslot_number organization {id name {name_en}} person {preferred_name}}} parent_activities {id name description avinya_type {id active global_type name foundation_type focus level description} notes activity_instances {id name description notes start_time end_time daily_sequence weekly_sequence monthly_sequence} activity_sequence_plan {id sequence_number timeslot_number organization {id name {name_en}} person {preferred_name}}} activity_sequence_plan {id sequence_number timeslot_number organization {id name {name_en}} person {preferred_name}} activity_instances {id name description notes start_time end_time daily_sequence weekly_sequence monthly_sequence}}}`;
        map<anydata> variables = {"pcti_participant_id": pcti_participant_id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetPctiParticipantActivitiesResponse> check performDataBinding(graphqlResponse, GetPctiParticipantActivitiesResponse);
    }
    remote isolated function getActivityInstancesToday(int pcti_activity_id) returns GetActivityInstancesTodayResponse|graphql:ClientError {
        string query = string `query getActivityInstancesToday($pcti_activity_id:Int!) {activity_instances_today(activity_id:$pcti_activity_id) {id name description activity_id notes daily_sequence weekly_sequence monthly_sequence start_time end_time created updated activity_participants {id activity_instance_id person {preferred_name} organization {id name {name_en}} start_date end_date role notes created updated} activity_participant_attendances {id activity_instance_id person {preferred_name} sign_in_time sign_out_time created updated} evaluations {id evaluatee_id evaluator_id evaluation_criteria_id updated notes grade child_evaluations {id evaluatee_id evaluator_id evaluation_criteria_id updated notes grade} parent_evaluations {id evaluatee_id evaluator_id evaluation_criteria_id updated notes grade}}}}`;
        map<anydata> variables = {"pcti_activity_id": pcti_activity_id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetActivityInstancesTodayResponse> check performDataBinding(graphqlResponse, GetActivityInstancesTodayResponse);
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
    remote isolated function addPctiNotes(Evaluation evaluation) returns AddPctiNotesResponse|graphql:ClientError {
        string query = string `mutation addPctiNotes($evaluation:Evaluation!) {add_pcti_notes(evaluation:$evaluation) {id evaluatee_id evaluator_id evaluation_criteria_id updated notes grade child_evaluations {id evaluatee_id evaluator_id evaluation_criteria_id updated notes grade} parent_evaluations {id evaluatee_id evaluator_id evaluation_criteria_id updated notes grade}}}`;
        map<anydata> variables = {"evaluation": evaluation};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <AddPctiNotesResponse> check performDataBinding(graphqlResponse, AddPctiNotesResponse);
    }
    remote isolated function getPctiActivities() returns GetPctiActivitiesResponse|graphql:ClientError {
        string query = string `query getPctiActivities {pcti_activities {id name description avinya_type {id active global_type name foundation_type focus level description} notes child_activities {id name description avinya_type {id active global_type name foundation_type focus level description} notes activity_instances {id name description notes start_time end_time daily_sequence weekly_sequence monthly_sequence} activity_sequence_plan {id sequence_number timeslot_number organization {id name {name_en}} person {preferred_name}}} parent_activities {id name description avinya_type {id active global_type name foundation_type focus level description} notes activity_instances {id name description notes start_time end_time daily_sequence weekly_sequence monthly_sequence} activity_sequence_plan {id sequence_number timeslot_number organization {id name {name_en}} person {preferred_name}}} activity_sequence_plan {id sequence_number timeslot_number organization {id name {name_en}} person {preferred_name}} activity_instances {id name description notes start_time end_time daily_sequence weekly_sequence monthly_sequence}}}`;
        map<anydata> variables = {};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetPctiActivitiesResponse> check performDataBinding(graphqlResponse, GetPctiActivitiesResponse);
    }
    remote isolated function getActivityInstancesFuture(int activityId) returns GetActivityInstancesFutureResponse|graphql:ClientError {
        string query = string `query getActivityInstancesFuture($activityId:Int!) {activity_instances_future(activity_id:$activityId) {id name description activity_id notes daily_sequence weekly_sequence monthly_sequence start_time end_time created updated activity_participants {id activity_instance_id person {preferred_name} organization {id name {name_en}} start_date end_date role notes created updated} activity_participant_attendances {id activity_instance_id person {preferred_name} sign_in_time sign_out_time created updated} evaluations {id evaluatee_id evaluator_id evaluation_criteria_id updated notes grade child_evaluations {id evaluatee_id evaluator_id evaluation_criteria_id updated notes grade} parent_evaluations {id evaluatee_id evaluator_id evaluation_criteria_id updated notes grade}}}}`;
        map<anydata> variables = {"activityId": activityId};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetActivityInstancesFutureResponse> check performDataBinding(graphqlResponse, GetActivityInstancesFutureResponse);
    }
    remote isolated function getAvailableTeachers(int activityInstanceId) returns GetAvailableTeachersResponse|graphql:ClientError {
        string query = string `query getAvailableTeachers($activityInstanceId:Int!) {available_teachers(activity_instance_id:$activityInstanceId) {id preferred_name full_name date_of_birth sex asgardeo_id jwt_sub_id jwt_email permanent_address {id city {id name {name_en} district {id name {name_en} province {id name {name_en}}}}} mailing_address {id city {id name {name_en} district {id name {name_en} province {id name {name_en}}}}} phone organization {id name {name_en}} avinya_type {id active global_type name foundation_type focus level description} notes nic_no passport_no id_no email child_students {id preferred_name full_name date_of_birth} parent_students {id preferred_name full_name date_of_birth}}}`;
        map<anydata> variables = {"activityInstanceId": activityInstanceId};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetAvailableTeachersResponse> check performDataBinding(graphqlResponse, GetAvailableTeachersResponse);
    }
    remote isolated function addActivityParticipant(ActivityParticipant activityParticipant) returns AddActivityParticipantResponse|graphql:ClientError {
        string query = string `mutation addActivityParticipant($activityParticipant:ActivityParticipant!) {add_activity_participant(activityParticipant:$activityParticipant) {id activity_instance_id person {preferred_name} organization {id name {name_en}} start_date end_date role notes created updated}}`;
        map<anydata> variables = {"activityParticipant": activityParticipant};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <AddActivityParticipantResponse> check performDataBinding(graphqlResponse, AddActivityParticipantResponse);
    }
}

