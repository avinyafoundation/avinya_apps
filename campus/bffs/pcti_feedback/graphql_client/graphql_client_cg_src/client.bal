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
    remote isolated function getEvaluations(int eval_id) returns GetEvaluationsResponse|graphql:ClientError {
        string query = string `query getEvaluations($eval_id:Int!) {evaluation(eval_id:$eval_id) {id evaluatee_id evaluator_id evaluation_criteria_id activity_instance_id grade notes response updated}}`;
        map<anydata> variables = {"eval_id": eval_id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetEvaluationsResponse> check performDataBinding(graphqlResponse, GetEvaluationsResponse);
    }
    remote isolated function getEvaluationsAll() returns GetEvaluationsAllResponse|graphql:ClientError {
        string query = string `query getEvaluationsAll {all_evaluations {id evaluatee_id evaluator_id evaluation_criteria_id activity_instance_id grade notes response updated created}}`;
        map<anydata> variables = {};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetEvaluationsAllResponse> check performDataBinding(graphqlResponse, GetEvaluationsAllResponse);
    }
    remote isolated function updateEvaluation(Evaluation evaluation) returns UpdateEvaluationResponse|graphql:ClientError {
        string query = string `mutation updateEvaluation($evaluation:Evaluation!) {update_evaluation(evaluation:$evaluation) {id evaluatee_id evaluator_id evaluation_criteria_id activity_instance_id grade notes response updated}}`;
        map<anydata> variables = {"evaluation": evaluation};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <UpdateEvaluationResponse> check performDataBinding(graphqlResponse, UpdateEvaluationResponse);
    }
    remote isolated function getMetadata(int meta_evaluation_id) returns GetMetadataResponse|graphql:ClientError {
        string query = string `query getMetadata($meta_evaluation_id:Int!) {evaluation_meta_data(meta_evaluation_id:$meta_evaluation_id) {evaluation_id location on_date_time level meta_type status focus metadata}}`;
        map<anydata> variables = {"meta_evaluation_id": meta_evaluation_id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetMetadataResponse> check performDataBinding(graphqlResponse, GetMetadataResponse);
    }
    remote isolated function AddEvaluationMetaData(EvaluationMetadata metadata) returns AddEvaluationMetaDataResponse|graphql:ClientError {
        string query = string `mutation AddEvaluationMetaData($metadata:EvaluationMetadata!) {add_evaluation_meta_data(metadata:$metadata) {evaluation_id location level meta_type status focus metadata}}`;
        map<anydata> variables = {"metadata": metadata};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <AddEvaluationMetaDataResponse> check performDataBinding(graphqlResponse, AddEvaluationMetaDataResponse);
    }
    remote isolated function GetEvaluationCycle(int id) returns GetEvaluationCycleResponse|graphql:ClientError {
        string query = string `query GetEvaluationCycle($id:Int!) {evaluation_cycle(id:$id) {name description start_date end_date}}`;
        map<anydata> variables = {"id": id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetEvaluationCycleResponse> check performDataBinding(graphqlResponse, GetEvaluationCycleResponse);
    }
    remote isolated function AddEducationExperience(EducationExperience education_experience) returns AddEducationExperienceResponse|graphql:ClientError {
        string query = string `mutation AddEducationExperience($education_experience:EducationExperience!) {add_education_experience(education_experience:$education_experience) {person_id school start_date end_date}}`;
        map<anydata> variables = {"education_experience": education_experience};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <AddEducationExperienceResponse> check performDataBinding(graphqlResponse, AddEducationExperienceResponse);
    }
    remote isolated function GetEducationExperience(int person_id) returns GetEducationExperienceResponse|graphql:ClientError {
        string query = string `query GetEducationExperience($person_id:Int!) {education_experience_byPerson(person_id:$person_id) {person_id school start_date end_date}}`;
        map<anydata> variables = {"person_id": person_id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetEducationExperienceResponse> check performDataBinding(graphqlResponse, GetEducationExperienceResponse);
    }
    remote isolated function GetWorkExperience(int person_id) returns GetWorkExperienceResponse|graphql:ClientError {
        string query = string `query GetWorkExperience($person_id:Int!) {work_experience_ByPerson(person_id:$person_id) {person_id organization start_date end_date}}`;
        map<anydata> variables = {"person_id": person_id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetWorkExperienceResponse> check performDataBinding(graphqlResponse, GetWorkExperienceResponse);
    }
    remote isolated function AddWorkExperience(WorkExperience work_experience) returns AddWorkExperienceResponse|graphql:ClientError {
        string query = string `mutation AddWorkExperience($work_experience:WorkExperience!) {add_work_experience(work_experience:$work_experience) {person_id organization start_date end_date}}`;
        map<anydata> variables = {"work_experience": work_experience};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <AddWorkExperienceResponse> check performDataBinding(graphqlResponse, AddWorkExperienceResponse);
    }
    remote isolated function GetEvaluationCriteria(int id, string prompt) returns GetEvaluationCriteriaResponse|graphql:ClientError {
        string query = string `query GetEvaluationCriteria($prompt:String!,$id:Int!) {evaluationCriteria(prompt:$prompt,id:$id) {prompt description expected_answer evaluation_type difficulty rating_out_of id answer_options {answer expected_answer evaluation_criteria_id}}}`;
        map<anydata> variables = {"id": id, "prompt": prompt};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetEvaluationCriteriaResponse> check performDataBinding(graphqlResponse, GetEvaluationCriteriaResponse);
    }
    remote isolated function AddEvaluationanswerOption(EvaluationCriteriaAnswerOption evaluationAnswer) returns AddEvaluationanswerOptionResponse|graphql:ClientError {
        string query = string `mutation AddEvaluationanswerOption($evaluationAnswer:EvaluationCriteriaAnswerOption!) {add_evaluation_answer_option(evaluationAnswer:$evaluationAnswer) {answer expected_answer evaluation_criteria_id}}`;
        map<anydata> variables = {"evaluationAnswer": evaluationAnswer};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <AddEvaluationanswerOptionResponse> check performDataBinding(graphqlResponse, AddEvaluationanswerOptionResponse);
    }
    remote isolated function AddPctiActivityNotesEvaluation(Evaluation evaluation) returns AddPctiActivityNotesEvaluationResponse|graphql:ClientError {
        string query = string `mutation AddPctiActivityNotesEvaluation($evaluation:Evaluation!) {add_pcti_notes(evaluation:$evaluation) {id evaluatee_id evaluator_id evaluation_criteria_id activity_instance_id grade notes response updated}}`;
        map<anydata> variables = {"evaluation": evaluation};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <AddPctiActivityNotesEvaluationResponse> check performDataBinding(graphqlResponse, AddPctiActivityNotesEvaluationResponse);
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
    remote isolated function getPerson(string? name = (), int? id = ()) returns GetPersonResponse|graphql:ClientError {
        string query = string `query getPerson($id:Int,$name:String) {person(id:$id,name:$name) {id preferred_name full_name date_of_birth sex asgardeo_id jwt_sub_id jwt_email permanent_address {id city {id name {name_en} district {id name {name_en} province {id name {name_en}}}}} mailing_address {id city {id name {name_en} district {id name {name_en} province {id name {name_en}}}}} phone organization {id name {name_en}} avinya_type {id active global_type name foundation_type focus level description} notes nic_no passport_no id_no email child_students {id preferred_name full_name date_of_birth} parent_students {id preferred_name full_name date_of_birth}}}`;
        map<anydata> variables = {"name": name, "id": id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetPersonResponse> check performDataBinding(graphqlResponse, GetPersonResponse);
    }
    remote isolated function getActivity(string? name = (), int? id = ()) returns GetActivityResponse|graphql:ClientError {
        string query = string `query getActivity($name:String,$id:Int) {activity(name:$name,id:$id) {id name description avinya_type {id active global_type name foundation_type focus level description} notes child_activities {id name description avinya_type {id active global_type name foundation_type focus level description} notes activity_instances {id name description notes start_time end_time daily_sequence weekly_sequence monthly_sequence} activity_sequence_plan {id sequence_number timeslot_number organization {id name {name_en}} person {preferred_name}}} parent_activities {id name description avinya_type {id active global_type name foundation_type focus level description} notes activity_instances {id name description notes start_time end_time daily_sequence weekly_sequence monthly_sequence} activity_sequence_plan {id sequence_number timeslot_number organization {id name {name_en}} person {preferred_name}}} activity_sequence_plan {id sequence_number timeslot_number organization {id name {name_en}} person {preferred_name}} activity_instances {id name description notes start_time end_time daily_sequence weekly_sequence monthly_sequence}}}`;
        map<anydata> variables = {"name": name, "id": id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetActivityResponse> check performDataBinding(graphqlResponse, GetActivityResponse);
    }
    remote isolated function getPctiActivities() returns GetPctiActivitiesResponse|graphql:ClientError {
        string query = string `query getPctiActivities {pcti_activities {id name description avinya_type {id active global_type name foundation_type focus level description} notes child_activities {id name description avinya_type {id active global_type name foundation_type focus level description} notes activity_instances {id name description notes start_time end_time daily_sequence weekly_sequence monthly_sequence} activity_sequence_plan {id sequence_number timeslot_number organization {id name {name_en}} person {preferred_name}}} parent_activities {id name description avinya_type {id active global_type name foundation_type focus level description} notes activity_instances {id name description notes start_time end_time daily_sequence weekly_sequence monthly_sequence} activity_sequence_plan {id sequence_number timeslot_number organization {id name {name_en}} person {preferred_name}}} activity_sequence_plan {id sequence_number timeslot_number organization {id name {name_en}} person {preferred_name}} activity_instances {id name description notes start_time end_time daily_sequence weekly_sequence monthly_sequence}}}`;
        map<anydata> variables = {};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetPctiActivitiesResponse> check performDataBinding(graphqlResponse, GetPctiActivitiesResponse);
    }
    remote isolated function getPctiParticipantActivities(int pcti_participant_id) returns GetPctiParticipantActivitiesResponse|graphql:ClientError {
        string query = string `query getPctiParticipantActivities($pcti_participant_id:Int!) {pcti_participant_activities(participant_id:$pcti_participant_id) {id name description avinya_type {id active global_type name foundation_type focus level description} notes child_activities {id name description avinya_type {id active global_type name foundation_type focus level description} notes activity_instances {id name description notes start_time end_time daily_sequence weekly_sequence monthly_sequence} activity_sequence_plan {id sequence_number timeslot_number organization {id name {name_en}} person {preferred_name}}} parent_activities {id name description avinya_type {id active global_type name foundation_type focus level description} notes activity_instances {id name description notes start_time end_time daily_sequence weekly_sequence monthly_sequence} activity_sequence_plan {id sequence_number timeslot_number organization {id name {name_en}} person {preferred_name}}} activity_sequence_plan {id sequence_number timeslot_number organization {id name {name_en}} person {preferred_name}} activity_instances {id name description notes start_time end_time daily_sequence weekly_sequence monthly_sequence}}}`;
        map<anydata> variables = {"pcti_participant_id": pcti_participant_id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetPctiParticipantActivitiesResponse> check performDataBinding(graphqlResponse, GetPctiParticipantActivitiesResponse);
    }
}
