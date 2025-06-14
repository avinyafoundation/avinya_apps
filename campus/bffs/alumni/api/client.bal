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

    remote isolated function createAlumni(Alumni alumni, Person person, Address? mailing_address = (), City? mailing_address_city = ()) returns CreateAlumniResponse|graphql:ClientError {
        string query = string `mutation createAlumni($person:Person!,$mailing_address:Address,$mailing_address_city:City,$alumni:Alumni!) {create_alumni(person:$person,mailing_address:$mailing_address,mailing_address_city:$mailing_address_city,alumni:$alumni) {id preferred_name full_name mailing_address {city {id name {name_en name_si name_ta} district {id name {name_en}}} street_address phone id} alumni {id status company_name job_title linkedin_id facebook_id instagram_id tiktok_id} phone email documents_id alumni_id}}`;
        map<anydata> variables = {"mailing_address": mailing_address, "alumni": alumni, "person": person, "mailing_address_city": mailing_address_city};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <CreateAlumniResponse>check performDataBinding(graphqlResponse, CreateAlumniResponse);
    }
    remote isolated function updateAlumni(Alumni alumni, Person person, Address? mailing_address = (), City? mailing_address_city = ()) returns UpdateAlumniResponse|graphql:ClientError {
        string query = string `mutation updateAlumni($person:Person!,$mailing_address:Address,$mailing_address_city:City,$alumni:Alumni!) {update_alumni(person:$person,mailing_address:$mailing_address,mailing_address_city:$mailing_address_city,alumni:$alumni) {id preferred_name full_name mailing_address {city {id name {name_en name_si name_ta} district {id name {name_en}}} street_address phone id} alumni {id status company_name job_title linkedin_id facebook_id instagram_id tiktok_id} phone email documents_id alumni_id}}`;
        map<anydata> variables = {"mailing_address": mailing_address, "alumni": alumni, "person": person, "mailing_address_city": mailing_address_city};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <UpdateAlumniResponse>check performDataBinding(graphqlResponse, UpdateAlumniResponse);
    }

    remote isolated function createAlumniEducationQualification(AlumniEducationQualification alumni_education_qualification) returns CreateAlumniEducationQualificationResponse|graphql:ClientError {
        string query = string `mutation createAlumniEducationQualification($alumni_education_qualification:AlumniEducationQualification!) {create_alumni_education_qualification(alumni_education_qualification:$alumni_education_qualification) {id person_id university_name course_name is_currently_studying start_date end_date created updated}}`;
        map<anydata> variables = {"alumni_education_qualification": alumni_education_qualification};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <CreateAlumniEducationQualificationResponse>check performDataBinding(graphqlResponse, CreateAlumniEducationQualificationResponse);
    }
    remote isolated function createAlumniWorkExperience(AlumniWorkExperience alumni_work_experience) returns CreateAlumniWorkExperienceResponse|graphql:ClientError {
        string query = string `mutation createAlumniWorkExperience($alumni_work_experience:AlumniWorkExperience!) {create_alumni_work_experience(alumni_work_experience:$alumni_work_experience) {id person_id company_name job_title currently_working start_date end_date created updated}}`;
        map<anydata> variables = {"alumni_work_experience": alumni_work_experience};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <CreateAlumniWorkExperienceResponse>check performDataBinding(graphqlResponse, CreateAlumniWorkExperienceResponse);
    }
    remote isolated function updateAlumniEducationQualification(AlumniEducationQualification alumni_education_qualification) returns UpdateAlumniEducationQualificationResponse|graphql:ClientError {
        string query = string `mutation updateAlumniEducationQualification($alumni_education_qualification:AlumniEducationQualification!) {update_alumni_education_qualification(alumni_education_qualification:$alumni_education_qualification) {id person_id university_name course_name is_currently_studying start_date end_date created updated}}`;
        map<anydata> variables = {"alumni_education_qualification": alumni_education_qualification};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <UpdateAlumniEducationQualificationResponse>check performDataBinding(graphqlResponse, UpdateAlumniEducationQualificationResponse);
    }
    remote isolated function updateAlumniWorkExperience(AlumniWorkExperience alumni_work_experience) returns UpdateAlumniWorkExperienceResponse|graphql:ClientError {
        string query = string `mutation updateAlumniWorkExperience($alumni_work_experience:AlumniWorkExperience!) {update_alumni_work_experience(alumni_work_experience:$alumni_work_experience) {id person_id company_name job_title currently_working start_date end_date created updated}}`;
        map<anydata> variables = {"alumni_work_experience": alumni_work_experience};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <UpdateAlumniWorkExperienceResponse>check performDataBinding(graphqlResponse, UpdateAlumniWorkExperienceResponse);
    }

    remote isolated function deleteAlumniEducationQualificationById(int id) returns json|error {
        string query = string `mutation deleteAlumniEducationQualificationById($id: Int!) {delete_alumni_education_qualification_by_id(id:$id)}`;
        map<anydata> variables = {"id": id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        map<json> responseMap = <map<json>>graphqlResponse;
        json responseData = responseMap.get("data");
        json|error row_count = check responseData.delete_alumni_education_qualification_by_id;
        return row_count;
    }

    remote isolated function deleteAlumniWorkExperienceById(int id) returns json|error {
        string query = string `mutation deleteAlumniWorkExperienceById($id: Int!){delete_alumni_work_experience_by_id(id:$id)}`;
        map<anydata> variables = {"id": id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        map<json> responseMap = <map<json>>graphqlResponse;
        json responseData = responseMap.get("data");
        json|error row_count = check responseData.delete_alumni_work_experience_by_id;
        return row_count;
    }

    remote isolated function getAlumniEducationQualificationById(int id) returns GetAlumniEducationQualificationByIdResponse|graphql:ClientError {
        string query = string `query getAlumniEducationQualificationById($id:Int!) {alumni_education_qualification_by_id(id:$id) {id person_id university_name course_name is_currently_studying start_date end_date}}`;
        map<anydata> variables = {"id": id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetAlumniEducationQualificationByIdResponse>check performDataBinding(graphqlResponse, GetAlumniEducationQualificationByIdResponse);
    }
    remote isolated function getAlumniWorkExperienceById(int id) returns GetAlumniWorkExperienceByIdResponse|graphql:ClientError {
        string query = string `query getAlumniWorkExperienceById($id:Int!) {alumni_work_experience_by_id(id:$id) {id person_id company_name job_title currently_working start_date end_date}}`;
        map<anydata> variables = {"id": id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetAlumniWorkExperienceByIdResponse>check performDataBinding(graphqlResponse, GetAlumniWorkExperienceByIdResponse);
    }
    remote isolated function getAlumniPersonById(int id) returns GetAlumniPersonByIdResponse|graphql:ClientError {
        string query = string `query getAlumniPersonById($id:Int!) {person_by_id(id:$id) {id preferred_name full_name date_of_birth sex mailing_address {city {id name {name_en name_si name_ta} district {id name {name_en}}} street_address phone id} phone organization {id description notes address {id} avinya_type {id name} name {name_en} parent_organizations {id name {name_en}}} nic_no id_no email alumni {id status company_name job_title linkedin_id facebook_id instagram_id tiktok_id} alumni_education_qualifications {id person_id university_name course_name is_currently_studying start_date end_date} alumni_work_experience {id person_id company_name job_title currently_working start_date end_date} profile_picture {id picture}}}`;
        map<anydata> variables = {"id": id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetAlumniPersonByIdResponse>check performDataBinding(graphqlResponse, GetAlumniPersonByIdResponse);
    }
    remote isolated function createActivityParticipant(ActivityParticipant activity_participant) returns CreateActivityParticipantResponse|graphql:ClientError {
        string query = string `mutation createActivityParticipant($activity_participant:ActivityParticipant!) {create_activity_participant(activity_participant:$activity_participant) {id activity_instance_id person_id organization_id is_attending created updated}}`;
        map<anydata> variables = {"activity_participant": activity_participant};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <CreateActivityParticipantResponse>check performDataBinding(graphqlResponse, CreateActivityParticipantResponse);
    }
    remote isolated function updateActivityParticipant(ActivityParticipant activity_participant) returns UpdateActivityParticipantResponse|graphql:ClientError {
        string query = string `mutation updateActivityParticipant($activity_participant:ActivityParticipant!) {create_activity_participant(activity_participant:$activity_participant) {id activity_instance_id person_id organization_id is_attending created updated}}`;
        map<anydata> variables = {"activity_participant": activity_participant};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <UpdateActivityParticipantResponse>check performDataBinding(graphqlResponse, UpdateActivityParticipantResponse);
    }
    remote isolated function createActivityInstanceEvaluation(ActivityInstanceEvaluation activity_instance_evaluation) returns CreateActivityInstanceEvaluationResponse|graphql:ClientError {
        string query = string `mutation createActivityInstanceEvaluation($activity_instance_evaluation:ActivityInstanceEvaluation!) {create_activity_instance_evaluation(activity_instance_evaluation:$activity_instance_evaluation) {id activity_instance_id evaluator_id feedback rating created updated}}`;
        map<anydata> variables = {"activity_instance_evaluation": activity_instance_evaluation};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <CreateActivityInstanceEvaluationResponse>check performDataBinding(graphqlResponse, CreateActivityInstanceEvaluationResponse);
    }

    remote isolated function getUpcomingEvents(int person_id) returns GetUpcomingEventsResponse|graphql:ClientError {
        string query = string `query getUpcomingEvents($person_id:Int!) {upcoming_events(person_id:$person_id) {id activity_id name location description start_time end_time event_gift {activity_instance_id gift_amount no_of_gifts notes description} activity_participant {id activity_instance_id is_attending}}}`;
        map<anydata> variables = {"person_id": person_id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetUpcomingEventsResponse>check performDataBinding(graphqlResponse, GetUpcomingEventsResponse);
    }
    remote isolated function getCompletedEvents(int person_id) returns GetCompletedEventsResponse|graphql:ClientError {
        string query = string `query getCompletedEvents($person_id:Int!) {completed_events(person_id:$person_id) {id activity_id name location description start_time end_time activity_evaluation {activity_instance_id evaluator_id feedback rating}}}`;
        map<anydata> variables = {"person_id": person_id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetCompletedEventsResponse>check performDataBinding(graphqlResponse, GetCompletedEventsResponse);
    }

    remote isolated function getAlumniPersons(int parent_organization_id) returns GetAlumniPersonsResponse|graphql:ClientError {
        string query = string `query getAlumniPersons($parent_organization_id:Int!) {alumni_persons(parent_organization_id:$parent_organization_id) {id preferred_name full_name email phone nic_no alumni {id status company_name job_title updated_by updated}}}`;
        map<anydata> variables = {"parent_organization_id": parent_organization_id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetAlumniPersonsResponse>check performDataBinding(graphqlResponse, GetAlumniPersonsResponse);
    }
    remote isolated function getAlumniSummary(int alumni_batch_id) returns GetAlumniSummaryResponse|graphql:ClientError {
        string query = string `query getAlumniSummary($alumni_batch_id:Int!) {alumni_summary(alumni_batch_id:$alumni_batch_id) {status person_count}}`;
        map<anydata> variables = {"alumni_batch_id": alumni_batch_id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetAlumniSummaryResponse>check performDataBinding(graphqlResponse, GetAlumniSummaryResponse);
    }
    remote isolated function uploadPersonProfilePicture(PersonProfilePicture person_profile_picture) returns UploadPersonProfilePictureResponse|graphql:ClientError {
        string query = string `mutation uploadPersonProfilePicture($person_profile_picture:PersonProfilePicture!) {upload_person_profile_picture(person_profile_picture:$person_profile_picture) {id person_id profile_picture_drive_id uploaded_by}}`;
        map<anydata> variables = {"person_profile_picture": person_profile_picture};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <UploadPersonProfilePictureResponse>check performDataBinding(graphqlResponse, UploadPersonProfilePictureResponse);
    }

    remote isolated function deletePersonProfilePictureById(int id) returns json|error {
        string query = string `mutation deletePersonProfilePictureById($id: Int!){delete_person_profile_picture_by_id(id:$id)}`;
        map<anydata> variables = {"id": id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        map<json> responseMap = <map<json>>graphqlResponse;
        json responseData = responseMap.get("data");
        json|error row_count = check responseData.delete_person_profile_picture_by_id;
        return row_count;
    }
}
