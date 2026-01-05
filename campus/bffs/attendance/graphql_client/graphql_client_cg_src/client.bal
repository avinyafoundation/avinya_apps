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
    remote isolated function getClassAttendanceReport(string from_date, string to_date, int result_limit, int organization_id, int activity_id) returns GetClassAttendanceReportResponse|graphql:ClientError {
        string query = string `query getClassAttendanceReport($organization_id:Int!,$activity_id:Int!,$result_limit:Int!,$from_date:String!,$to_date:String!) {class_attendance_report(organization_id:$organization_id,activity_id:$activity_id,result_limit:$result_limit,from_date:$from_date,to_date:$to_date) {id person {id} activity_instance_id sign_in_time sign_out_time in_marked_by out_marked_by}}`;
        map<anydata> variables = {"from_date": from_date, "to_date": to_date, "result_limit": result_limit, "organization_id": organization_id, "activity_id": activity_id};
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
    remote isolated function updateEvaluations(Evaluation evaluation) returns UpdateEvaluationsResponse|graphql:ClientError {
        string query = string `mutation updateEvaluations($evaluation:Evaluation!) {update_evaluation(evaluation:$evaluation) {id evaluatee_id evaluator_id evaluation_criteria_id response notes grade activity_instance_id updated}}`;
        map<anydata> variables = {"evaluation": evaluation};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <UpdateEvaluationsResponse> check performDataBinding(graphqlResponse, UpdateEvaluationsResponse);
    }
    remote isolated function getDutyParticipants(int organization_id) returns GetDutyParticipantsResponse|graphql:ClientError {
        string query = string `query getDutyParticipants($organization_id:Int!) {duty_participants(organization_id:$organization_id) {id activity {id name description} person {id preferred_name digital_id organization {name {name_en} description}} role}}`;
        map<anydata> variables = {"organization_id": organization_id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetDutyParticipantsResponse> check performDataBinding(graphqlResponse, GetDutyParticipantsResponse);
    }
    remote isolated function createDutyForParticipant(DutyParticipant dutyparticipant) returns CreateDutyForParticipantResponse|graphql:ClientError {
        string query = string `mutation createDutyForParticipant($dutyparticipant:DutyParticipant!) {add_duty_for_participant(dutyparticipant:$dutyparticipant) {id activity_id person_id role created}}`;
        map<anydata> variables = {"dutyparticipant": dutyparticipant};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <CreateDutyForParticipantResponse> check performDataBinding(graphqlResponse, CreateDutyForParticipantResponse);
    }
    remote isolated function getActivitiesByAvinyaType(int avinya_type_id) returns GetActivitiesByAvinyaTypeResponse|graphql:ClientError {
        string query = string `query getActivitiesByAvinyaType($avinya_type_id:Int!) {activities_by_avinya_type(avinya_type_id:$avinya_type_id) {id name description notes}}`;
        map<anydata> variables = {"avinya_type_id": avinya_type_id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetActivitiesByAvinyaTypeResponse> check performDataBinding(graphqlResponse, GetActivitiesByAvinyaTypeResponse);
    }
    remote isolated function updateDutyRotationMetaData(DutyRotationMetaDetails dutyRotation) returns UpdateDutyRotationMetaDataResponse|graphql:ClientError {
        string query = string `mutation updateDutyRotationMetaData($dutyRotation:DutyRotationMetaDetails!) {update_duty_rotation_metadata(duty_rotation:$dutyRotation) {id start_date end_date organization_id}}`;
        map<anydata> variables = {"dutyRotation": dutyRotation};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <UpdateDutyRotationMetaDataResponse> check performDataBinding(graphqlResponse, UpdateDutyRotationMetaDataResponse);
    }
    remote isolated function getDutyRotationMetadataByOrganization(int organization_id) returns GetDutyRotationMetadataByOrganizationResponse|graphql:ClientError {
        string query = string `query getDutyRotationMetadataByOrganization($organization_id:Int!) {duty_rotation_metadata_by_organization(organization_id:$organization_id) {id start_date end_date organization_id}}`;
        map<anydata> variables = {"organization_id": organization_id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetDutyRotationMetadataByOrganizationResponse> check performDataBinding(graphqlResponse, GetDutyRotationMetadataByOrganizationResponse);
    }
    remote isolated function getDutyParticipantsByDutyActivityId(int organization_id, int duty_activity_id) returns GetDutyParticipantsByDutyActivityIdResponse|graphql:ClientError {
        string query = string `query getDutyParticipantsByDutyActivityId($organization_id:Int!,$duty_activity_id:Int!) {duty_participants_by_duty_activity_id(organization_id:$organization_id,duty_activity_id:$duty_activity_id) {id activity {id name description} person {id preferred_name digital_id organization {name {name_en} description}} role}}`;
        map<anydata> variables = {"organization_id": organization_id, "duty_activity_id": duty_activity_id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetDutyParticipantsByDutyActivityIdResponse> check performDataBinding(graphqlResponse, GetDutyParticipantsByDutyActivityIdResponse);
    }
    remote isolated function addDutyAttendance(ActivityParticipantAttendance duty_attendance) returns AddDutyAttendanceResponse|graphql:ClientError {
        string query = string `mutation addDutyAttendance($duty_attendance:ActivityParticipantAttendance!) {add_duty_attendance(duty_attendance:$duty_attendance) {id activity_instance_id person_id sign_in_time sign_out_time in_marked_by out_marked_by created}}`;
        map<anydata> variables = {"duty_attendance": duty_attendance};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <AddDutyAttendanceResponse> check performDataBinding(graphqlResponse, AddDutyAttendanceResponse);
    }
    remote isolated function getDutyAttendanceToday(int organization_id, int activity_id) returns GetDutyAttendanceTodayResponse|graphql:ClientError {
        string query = string `query getDutyAttendanceToday($organization_id:Int!,$activity_id:Int!) {duty_attendance_today(organization_id:$organization_id,activity_id:$activity_id) {id person_id activity_instance_id sign_in_time sign_out_time in_marked_by out_marked_by created}}`;
        map<anydata> variables = {"organization_id": organization_id, "activity_id": activity_id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetDutyAttendanceTodayResponse> check performDataBinding(graphqlResponse, GetDutyAttendanceTodayResponse);
    }
    remote isolated function getDutyParticipant(int person_id) returns GetDutyParticipantResponse|graphql:ClientError {
        string query = string `query getDutyParticipant($person_id:Int!) {duty_participant(person_id:$person_id) {id activity {id name description} person {id preferred_name digital_id organization {name {name_en} description}} role}}`;
        map<anydata> variables = {"person_id": person_id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetDutyParticipantResponse> check performDataBinding(graphqlResponse, GetDutyParticipantResponse);
    }
    remote isolated function getAttendanceDashboard(string from_date, string to_date, int organization_id) returns GetAttendanceDashboardResponse|graphql:ClientError {
        string query = string `query getAttendanceDashboard($organization_id:Int!,$from_date:String!,$to_date:String!) {attendance_dashboard_data_by_date(organization_id:$organization_id,from_date:$from_date,to_date:$to_date) {attendance_dashboard_data {title numOfFiles svgSrc color percentage}}}`;
        map<anydata> variables = {"from_date": from_date, "to_date": to_date, "organization_id": organization_id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetAttendanceDashboardResponse> check performDataBinding(graphqlResponse, GetAttendanceDashboardResponse);
    }
    remote isolated function getLateAttendanceReport(string from_date, string to_date, int organization_id, int activity_id) returns GetLateAttendanceReportResponse|graphql:ClientError {
        string query = string `query getLateAttendanceReport($organization_id:Int!,$activity_id:Int!,$from_date:String!,$to_date:String!) {late_attendance_report(organization_id:$organization_id,activity_id:$activity_id,from_date:$from_date,to_date:$to_date) {id person {id} activity_instance_id sign_in_time sign_out_time in_marked_by out_marked_by preferred_name digital_id person_id}}`;
        map<anydata> variables = {"from_date": from_date, "to_date": to_date, "organization_id": organization_id, "activity_id": activity_id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetLateAttendanceReportResponse> check performDataBinding(graphqlResponse, GetLateAttendanceReportResponse);
    }
    remote isolated function createDutyEvaluation(Evaluation duty_evaluation) returns CreateDutyEvaluationResponse|graphql:ClientError {
        string query = string `mutation createDutyEvaluation($duty_evaluation:Evaluation!) {add_duty_evaluation(duty_evaluation:$duty_evaluation) {id evaluatee_id evaluator_id evaluation_criteria_id activity_instance_id response notes grade created}}`;
        map<anydata> variables = {"duty_evaluation": duty_evaluation};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <CreateDutyEvaluationResponse> check performDataBinding(graphqlResponse, CreateDutyEvaluationResponse);
    }
    remote isolated function getAttendanceMissedBySecurityByOrg(string from_date, string to_date, int organization_id) returns GetAttendanceMissedBySecurityByOrgResponse|graphql:ClientError {
        string query = string `query getAttendanceMissedBySecurityByOrg($organization_id:Int!,$from_date:String!,$to_date:String!) {attendance_missed_by_security(organization_id:$organization_id,from_date:$from_date,to_date:$to_date) {preferred_name digital_id description sign_in_time}}`;
        map<anydata> variables = {"from_date": from_date, "to_date": to_date, "organization_id": organization_id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetAttendanceMissedBySecurityByOrgResponse> check performDataBinding(graphqlResponse, GetAttendanceMissedBySecurityByOrgResponse);
    }
    remote isolated function getAttendanceMissedBySecurityByParentOrg(string from_date, string to_date, int parent_organization_id) returns GetAttendanceMissedBySecurityByParentOrgResponse|graphql:ClientError {
        string query = string `query getAttendanceMissedBySecurityByParentOrg($parent_organization_id:Int!,$from_date:String!,$to_date:String!) {attendance_missed_by_security(parent_organization_id:$parent_organization_id,from_date:$from_date,to_date:$to_date) {preferred_name digital_id description sign_in_time}}`;
        map<anydata> variables = {"from_date": from_date, "to_date": to_date, "parent_organization_id": parent_organization_id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetAttendanceMissedBySecurityByParentOrgResponse> check performDataBinding(graphqlResponse, GetAttendanceMissedBySecurityByParentOrgResponse);
    }
    remote isolated function getDailyStudentsAttendanceByParentOrg(int parent_organization_id) returns GetDailyStudentsAttendanceByParentOrgResponse|graphql:ClientError {
        string query = string `query getDailyStudentsAttendanceByParentOrg($parent_organization_id:Int!) {daily_students_attendance_by_parent_org(parent_organization_id:$parent_organization_id) {description present_count total_student_count svg_src color}}`;
        map<anydata> variables = {"parent_organization_id": parent_organization_id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetDailyStudentsAttendanceByParentOrgResponse> check performDataBinding(graphqlResponse, GetDailyStudentsAttendanceByParentOrgResponse);
    }
    remote isolated function getTotalAttendanceCountByDateByOrg(string from_date, string to_date, int organization_id) returns GetTotalAttendanceCountByDateByOrgResponse|graphql:ClientError {
        string query = string `query getTotalAttendanceCountByDateByOrg($organization_id:Int!,$from_date:String!,$to_date:String!) {total_attendance_count_by_date(organization_id:$organization_id,from_date:$from_date,to_date:$to_date) {attendance_date daily_total}}`;
        map<anydata> variables = {"from_date": from_date, "to_date": to_date, "organization_id": organization_id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetTotalAttendanceCountByDateByOrgResponse> check performDataBinding(graphqlResponse, GetTotalAttendanceCountByDateByOrgResponse);
    }
    remote isolated function getTotalAttendanceCountByParentOrg(string from_date, string to_date, int parent_organization_id) returns GetTotalAttendanceCountByParentOrgResponse|graphql:ClientError {
        string query = string `query getTotalAttendanceCountByParentOrg($parent_organization_id:Int!,$from_date:String!,$to_date:String!) {total_attendance_count_by_date(parent_organization_id:$parent_organization_id,from_date:$from_date,to_date:$to_date) {attendance_date daily_total}}`;
        map<anydata> variables = {"from_date": from_date, "to_date": to_date, "parent_organization_id": parent_organization_id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetTotalAttendanceCountByParentOrgResponse> check performDataBinding(graphqlResponse, GetTotalAttendanceCountByParentOrgResponse);
    }
    remote isolated function getDailyAttendanceSummaryReport(string from_date, string to_date, int organization_id, int avinya_type_id) returns GetDailyAttendanceSummaryReportResponse|graphql:ClientError {
        string query = string `query getDailyAttendanceSummaryReport($organization_id:Int!,$avinya_type_id:Int!,$from_date:String!,$to_date:String!) {daily_attendance_summary_report(organization_id:$organization_id,avinya_type_id:$avinya_type_id,from_date:$from_date,to_date:$to_date) {sign_in_date present_count absent_count late_count total_count present_attendance_percentage absent_attendance_percentage late_attendance_percentage}}`;
        map<anydata> variables = {"from_date": from_date, "to_date": to_date, "organization_id": organization_id, "avinya_type_id": avinya_type_id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetDailyAttendanceSummaryReportResponse> check performDataBinding(graphqlResponse, GetDailyAttendanceSummaryReportResponse);
    }
    remote isolated function getOrganizationsByAvinyaTypeAndStatus(int? avinya_type = (), int? active = ()) returns GetOrganizationsByAvinyaTypeAndStatusResponse|graphql:ClientError {
        string query = string `query getOrganizationsByAvinyaTypeAndStatus($avinya_type:Int,$active:Int) {organizations_by_avinya_type_and_status(avinya_type:$avinya_type,active:$active) {id name {name_en} description organization_metadata {key_name value}}}`;
        map<anydata> variables = {"avinya_type": avinya_type, "active": active};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetOrganizationsByAvinyaTypeAndStatusResponse> check performDataBinding(graphqlResponse, GetOrganizationsByAvinyaTypeAndStatusResponse);
    }
    remote isolated function createMonthlyLeaveDates(MonthlyLeaveDates monthlyLeaveDates) returns CreateMonthlyLeaveDatesResponse|graphql:ClientError {
        string query = string `mutation createMonthlyLeaveDates($monthlyLeaveDates:MonthlyLeaveDates!) {add_monthly_leave_dates(monthly_leave_dates:$monthlyLeaveDates) {id year month organization_id batch_id leave_dates_list daily_amount created updated}}`;
        map<anydata> variables = {"monthlyLeaveDates": monthlyLeaveDates};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <CreateMonthlyLeaveDatesResponse> check performDataBinding(graphqlResponse, CreateMonthlyLeaveDatesResponse);
    }
    remote isolated function updateMonthlyLeaveDates(MonthlyLeaveDates monthlyLeaveDates) returns UpdateMonthlyLeaveDatesResponse|graphql:ClientError {
        string query = string `mutation updateMonthlyLeaveDates($monthlyLeaveDates:MonthlyLeaveDates!) {update_monthly_leave_dates(monthly_leave_dates:$monthlyLeaveDates) {id year month organization_id batch_id leave_dates_list daily_amount created updated}}`;
        map<anydata> variables = {"monthlyLeaveDates": monthlyLeaveDates};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <UpdateMonthlyLeaveDatesResponse> check performDataBinding(graphqlResponse, UpdateMonthlyLeaveDatesResponse);
    }
    remote isolated function getMonthlyLeaveDatesRecordById(int month, int batch_id, int year, int organization_id) returns GetMonthlyLeaveDatesRecordByIdResponse|graphql:ClientError {
        string query = string `query getMonthlyLeaveDatesRecordById($organization_id:Int!,$batch_id:Int!,$year:Int!,$month:Int!) {monthly_leave_dates_record_by_id(organization_id:$organization_id,batch_id:$batch_id,year:$year,month:$month) {id year month organization_id batch_id leave_dates_list daily_amount created updated}}`;
        map<anydata> variables = {"month": month, "batch_id": batch_id, "year": year, "organization_id": organization_id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetMonthlyLeaveDatesRecordByIdResponse> check performDataBinding(graphqlResponse, GetMonthlyLeaveDatesRecordByIdResponse);
    }
    remote isolated function getBatchPaymentPlanByOrgId(string selected_month_date, int batch_id, int organization_id) returns GetBatchPaymentPlanByOrgIdResponse|graphql:ClientError {
        string query = string `query getBatchPaymentPlanByOrgId($organization_id:Int!,$batch_id:Int!,$selected_month_date:String!) {batch_payment_plan_by_org_id(organization_id:$organization_id,batch_id:$batch_id,selected_month_date:$selected_month_date) {id organization_id batch_id monthly_payment_amount}}`;
        map<anydata> variables = {"selected_month_date": selected_month_date, "batch_id": batch_id, "organization_id": organization_id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetBatchPaymentPlanByOrgIdResponse> check performDataBinding(graphqlResponse, GetBatchPaymentPlanByOrgIdResponse);
    }
}
