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
        string query = string `mutation createAlumni($person:Person!,$mailing_address:Address,$mailing_address_city:City,$alumni:Alumni!) {create_alumni(person:$person,mailing_address:$mailing_address,mailing_address_city:$mailing_address_city,alumni:$alumni) {id preferred_name full_name mailing_address {city {id name {name_en name_si name_ta}} street_address phone id} phone email documents_id alumni_id}}`;
        map<anydata> variables = {"mailing_address": mailing_address, "alumni": alumni, "person": person, "mailing_address_city": mailing_address_city};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <CreateAlumniResponse>check performDataBinding(graphqlResponse, CreateAlumniResponse);
    }
    remote isolated function updateAlumni(Alumni alumni, Person person, Address? mailing_address = (), City? mailing_address_city = ()) returns UpdateAlumniResponse|graphql:ClientError {
        string query = string `mutation updateAlumni($person:Person!,$mailing_address:Address,$mailing_address_city:City,$alumni:Alumni!) {update_alumni(person:$person,mailing_address:$mailing_address,mailing_address_city:$mailing_address_city,alumni:$alumni) {id preferred_name full_name mailing_address {city {id name {name_en name_si name_ta}} street_address phone id} phone email documents_id alumni_id}}`;
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
        json|error row_count = check responseData.delete_duty_for_participant;
        return row_count;
    }

    remote isolated function deleteAlumniWorkExperienceById(int id) returns json|error {
        string query = string `mutation deleteAlumniWorkExperienceById($id: Int!){delete_alumni_work_experience_by_id(id:$id)}`;
        map<anydata> variables = {"id": id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        map<json> responseMap = <map<json>>graphqlResponse;
        json responseData = responseMap.get("data");
        json|error row_count = check responseData.delete_duty_for_participant;
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
        string query = string `query getAlumniPersonById($id:Int!) {person_by_id(id:$id) {id preferred_name full_name date_of_birth mailing_address {city {id name {name_en name_si name_ta} district {id name {name_en}}} street_address phone id} phone organization {id description notes address {id} avinya_type {id name} name {name_en} parent_organizations {id name {name_en}}} nic_no id_no email alumni {id status company_name job_title linkedin_id facebook_id instagram_id} alumni_education_qualifications {id person_id university_name course_name is_currently_studying start_date end_date} alumni_work_experience {id person_id company_name job_title currently_working start_date end_date}}}`;
        map<anydata> variables = {"id": id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetAlumniPersonByIdResponse>check performDataBinding(graphqlResponse, GetAlumniPersonByIdResponse);
    }
}
