import ballerina/graphql;
import ballerina/http;
import ballerina/log;
import ballerina/mime;
import ballerina/io;
import ballerina/lang.array;


public function initClientConfig() returns ConnectionConfig {
    ConnectionConfig _clientConig = {};
    if (GLOBAL_DATA_USE_AUTH) {
        _clientConig.oauth2ClientCredentialsGrantConfig = {
            tokenUrl: CHOREO_TOKEN_URL,
            clientId: GLOBAL_DATA_CLIENT_ID,
            clientSecret: GLOBAL_DATA_CLIENT_SECRET
        };
    } else {
        _clientConig = {};
    }
    // log:printDebug("debug log");
    // log:printError("error log");
    // log:printInfo("info log");
    // log:printWarn("warn log");
    // log:printInfo("CHOREO_TOKEN_URL: " + CHOREO_TOKEN_URL);
    // log:printInfo("GLOBAL_DATA_CLIENT_ID: " + GLOBAL_DATA_CLIENT_ID);
    // log:printInfo("GLOBAL_DATA_CLIENT_SECRET: " + GLOBAL_DATA_CLIENT_SECRET);
    return _clientConig;
}

final GraphqlClient globalDataClient = check new (GLOBAL_DATA_API_URL,
    config = initClientConfig()
);

@http:ServiceConfig {
    cors: {
        allowOrigins: ["*"]
    }
}
service / on new http:Listener(9096) {

   

    resource function put update_alumni(@http:Payload Person person) returns Person|error {

        Alumni  alumni  = person?.alumni ?: {};
        Address? mailing_address = person?.mailing_address;
        City? mailing_address_city = mailing_address?.city;

        if(mailing_address is Address){
            mailing_address.city = ();
        }

        person.mailing_address = ();
        person.alumni = ();

        UpdateAlumniResponse|graphql:ClientError updateAlumniResponse = globalDataClient->updateAlumni(alumni,person,mailing_address,mailing_address_city);
        if (updateAlumniResponse is UpdateAlumniResponse) {
            Person|error alumni_record = updateAlumniResponse.update_alumni.cloneWithType(Person);
            if (alumni_record is Person) {
                return alumni_record;
            }
            else {
                return error("Error while processing Application record received: " + alumni_record.message() +
                    ":: Detail: " + alumni_record.detail().toString());
            }
        } else {
            log:printError("Error while updating record", updateAlumniResponse);
            return error("Error while updating record: " + updateAlumniResponse.message() +
                ":: Detail: " + updateAlumniResponse.detail().toString());
        }
    }

    resource function post create_alumni(@http:Payload Person person) returns Person|ErrorDetail|error {
        
        Alumni  alumni  = person?.alumni ?: {};
        Address? mailing_address = person?.mailing_address;
        City? mailing_address_city = mailing_address?.city;

        if(mailing_address is Address){
            mailing_address.city = ();
        }

        person.mailing_address = ();
        person.alumni = ();

        CreateAlumniResponse|graphql:ClientError createAlumniResponse = globalDataClient->createAlumni(alumni,person,mailing_address,mailing_address_city);
        if (createAlumniResponse is CreateAlumniResponse) {
            Person|error alumni_record = createAlumniResponse.create_alumni.cloneWithType(Person);
            if (alumni_record is Person) {
                return alumni_record;
            } else {
                log:printError("Error while processing Application record received", alumni_record);
                return {
                    "message": alumni_record.message().toString(),
                    "statusCode": "500"
                };
            }
        } else {
            log:printError("Error while creating application", createAlumniResponse);
            return {
                "message": createAlumniResponse.message().toString(),
                "statusCode": "500"
            };
        }
    }

    resource function post create_alumni_education_qualification(@http:Payload AlumniEducationQualification alumniEducationQualification) returns AlumniEducationQualification|error {
        CreateAlumniEducationQualificationResponse|graphql:ClientError createAlumniEducationQualificationResponse = globalDataClient->createAlumniEducationQualification(alumniEducationQualification);
        if(createAlumniEducationQualificationResponse is CreateAlumniEducationQualificationResponse) {
            AlumniEducationQualification|error alumni_education_qualification_record = createAlumniEducationQualificationResponse.create_alumni_education_qualification.cloneWithType(AlumniEducationQualification);
            if(alumni_education_qualification_record is AlumniEducationQualification) {
                return alumni_education_qualification_record;
            } else {
                log:printError("Error while processing Application record received", alumni_education_qualification_record);
                return error("Error while processing Application record received: " + alumni_education_qualification_record.message() + 
                    ":: Detail: " + alumni_education_qualification_record.detail().toString());
            }
        } else {
            log:printError("Error while creating application", createAlumniEducationQualificationResponse);
            return error("Error while creating application: " + createAlumniEducationQualificationResponse.message() + 
                ":: Detail: " + createAlumniEducationQualificationResponse.detail().toString());
        }
    }

    resource function post create_alumni_work_experience(@http:Payload AlumniWorkExperience alumniWorkExperience) returns AlumniWorkExperience|error {
        CreateAlumniWorkExperienceResponse|graphql:ClientError createAlumniWorkExperienceResponse = globalDataClient->createAlumniWorkExperience(alumniWorkExperience);
        if(createAlumniWorkExperienceResponse is CreateAlumniWorkExperienceResponse) {
            AlumniWorkExperience|error alumni_work_experience_record = createAlumniWorkExperienceResponse.create_alumni_work_experience.cloneWithType(AlumniWorkExperience);
            if(alumni_work_experience_record is AlumniWorkExperience) {
                return alumni_work_experience_record;
            } else {
                log:printError("Error while processing Application record received", alumni_work_experience_record);
                return error("Error while processing Application record received: " + alumni_work_experience_record.message() + 
                    ":: Detail: " + alumni_work_experience_record.detail().toString());
            }
        } else {
            log:printError("Error while creating application", createAlumniWorkExperienceResponse);
            return error("Error while creating application: " + createAlumniWorkExperienceResponse.message() + 
                ":: Detail: " + createAlumniWorkExperienceResponse.detail().toString());
        }
    }

    resource function put update_alumni_education_qualification(@http:Payload AlumniEducationQualification alumniEducationQualification) returns AlumniEducationQualification|error {
        UpdateAlumniEducationQualificationResponse|graphql:ClientError updateAlumniEducationQualificationResponse = globalDataClient->updateAlumniEducationQualification(alumniEducationQualification);
        if(updateAlumniEducationQualificationResponse is  UpdateAlumniEducationQualificationResponse) {
            AlumniEducationQualification|error alumni_education_qualification_data_record = updateAlumniEducationQualificationResponse.update_alumni_education_qualification.cloneWithType(AlumniEducationQualification);
            if(alumni_education_qualification_data_record is  AlumniEducationQualification) {
                return alumni_education_qualification_data_record;
            } else {
                log:printError("Error while processing Application record received", alumni_education_qualification_data_record);
                return error("Error while processing Application record received: " + alumni_education_qualification_data_record.message() + 
                    ":: Detail: " + alumni_education_qualification_data_record.detail().toString());
            }
        } else {
            log:printError("Error while updating application", updateAlumniEducationQualificationResponse);
            return error("Error while updating application: " + updateAlumniEducationQualificationResponse.message() + 
                ":: Detail: " + updateAlumniEducationQualificationResponse.detail().toString());
        }
    }

    resource function put update_alumni_work_experience(@http:Payload AlumniWorkExperience alumniWorkExperience) returns AlumniWorkExperience|error {
        UpdateAlumniWorkExperienceResponse|graphql:ClientError updateAlumniWorkExperienceResponse = globalDataClient->updateAlumniWorkExperience(alumniWorkExperience);
        if(updateAlumniWorkExperienceResponse is  UpdateAlumniWorkExperienceResponse) {
            AlumniWorkExperience|error alumni_work_experience_data_record = updateAlumniWorkExperienceResponse.update_alumni_work_experience.cloneWithType(AlumniWorkExperience);
            if(alumni_work_experience_data_record is  AlumniWorkExperience) {
                return alumni_work_experience_data_record;
            } else {
                log:printError("Error while processing Application record received", alumni_work_experience_data_record);
                return error("Error while processing Application record received: " + alumni_work_experience_data_record.message() + 
                    ":: Detail: " + alumni_work_experience_data_record.detail().toString());
            }
        } else {
            log:printError("Error while updating application", updateAlumniWorkExperienceResponse);
            return error("Error while updating application: " + updateAlumniWorkExperienceResponse.message() + 
                ":: Detail: " + updateAlumniWorkExperienceResponse.detail().toString());
        }
    }

    resource function delete alumni_education_qualification_by_id/[int id]() returns json|error {
        json|error delete_count = globalDataClient->deleteAlumniEducationQualificationById(id);
        return  delete_count;
    }

    resource function delete alumni_work_experience_by_id/[int id]() returns json|error {
        json|error delete_count = globalDataClient->deleteAlumniWorkExperienceById(id);
        return  delete_count;
    }

    resource function get alumni_education_qualification_by_id/[int id]() returns AlumniEducationQualification|error {
        GetAlumniEducationQualificationByIdResponse|graphql:ClientError getAlumniEducationQualificationByIdResponse = globalDataClient->getAlumniEducationQualificationById(id);
        if (getAlumniEducationQualificationByIdResponse is GetAlumniEducationQualificationByIdResponse) {
            AlumniEducationQualification|error alumni_education_qualification_by_id_record = getAlumniEducationQualificationByIdResponse.alumni_education_qualification_by_id.cloneWithType(AlumniEducationQualification);
            if (alumni_education_qualification_by_id_record is AlumniEducationQualification) {
                return alumni_education_qualification_by_id_record;
            } else {
                log:printError("Error while processing Application record received", alumni_education_qualification_by_id_record);
                return error("Error while processing Application record received: " + alumni_education_qualification_by_id_record.message() +
                    ":: Detail: " + alumni_education_qualification_by_id_record.detail().toString());
            }
        } else {
            log:printError("Error while creating application", getAlumniEducationQualificationByIdResponse);
            return error("Error while creating application: " + getAlumniEducationQualificationByIdResponse.message() +
                ":: Detail: " + getAlumniEducationQualificationByIdResponse.detail().toString());
        }
    }

    resource function get alumni_work_experience_by_id/[int id]() returns AlumniWorkExperience|error {
        GetAlumniWorkExperienceByIdResponse|graphql:ClientError getAlumniWorkExperienceByIdResponse = globalDataClient->getAlumniWorkExperienceById(id);
        if (getAlumniWorkExperienceByIdResponse is GetAlumniWorkExperienceByIdResponse) {
            AlumniWorkExperience|error alumni_work_experience_by_id_record = getAlumniWorkExperienceByIdResponse.alumni_work_experience_by_id.cloneWithType(AlumniWorkExperience);
            if (alumni_work_experience_by_id_record is AlumniWorkExperience) {
                return alumni_work_experience_by_id_record;
            } else {
                log:printError("Error while processing Application record received", alumni_work_experience_by_id_record);
                return error("Error while processing Application record received: " + alumni_work_experience_by_id_record.message() +
                    ":: Detail: " + alumni_work_experience_by_id_record.detail().toString());
            }
        } else {
            log:printError("Error while creating application", getAlumniWorkExperienceByIdResponse);
            return error("Error while creating application: " + getAlumniWorkExperienceByIdResponse.message() +
                ":: Detail: " + getAlumniWorkExperienceByIdResponse.detail().toString());
        }
    }

    resource function get alumni_person_by_id/[int id]() returns Person|error {
        GetAlumniPersonByIdResponse|graphql:ClientError getAlumniPersonByIdResponse = globalDataClient->getAlumniPersonById(id);
        if (getAlumniPersonByIdResponse is GetAlumniPersonByIdResponse) {
            Person|error person_by_id_record = getAlumniPersonByIdResponse.person_by_id.cloneWithType(Person);
            if (person_by_id_record is Person) {
                return person_by_id_record;
            } else {
                log:printError("Error while processing Application record received", person_by_id_record);
                return error("Error while processing Application record received: " + person_by_id_record.message() +
                    ":: Detail: " + person_by_id_record.detail().toString());
            }
        } else {
            log:printError("Error while creating application", getAlumniPersonByIdResponse);
            return error("Error while creating application: " + getAlumniPersonByIdResponse.message() +
                ":: Detail: " + getAlumniPersonByIdResponse.detail().toString());
        }
    }

    resource function post create_activity_participant(@http:Payload ActivityParticipant activityParticipant) returns ActivityParticipant|error {
        CreateActivityParticipantResponse|graphql:ClientError createActivityParticipantResponse = globalDataClient->createActivityParticipant(activityParticipant);
        if(createActivityParticipantResponse is CreateActivityParticipantResponse) {
            ActivityParticipant|error activity_participant_record = createActivityParticipantResponse.create_activity_participant.cloneWithType(ActivityParticipant);
            if(activity_participant_record is ActivityParticipant) {
                return activity_participant_record;
            } else {
                log:printError("Error while processing Application record received", activity_participant_record);
                return error("Error while processing Application record received: " + activity_participant_record.message() + 
                    ":: Detail: " + activity_participant_record.detail().toString());
            }
        } else {
            log:printError("Error while creating application", createActivityParticipantResponse);
            return error("Error while creating application: " + createActivityParticipantResponse.message() + 
                ":: Detail: " + createActivityParticipantResponse.detail().toString());
        }
    }

    resource function post create_activity_instance_evaluation(@http:Payload ActivityInstanceEvaluation activityInstanceEvaluation) returns ActivityInstanceEvaluation|error {
        CreateActivityInstanceEvaluationResponse|graphql:ClientError createActivityInstanceEvaluationResponse = globalDataClient->createActivityInstanceEvaluation(activityInstanceEvaluation);
        if(createActivityInstanceEvaluationResponse is CreateActivityInstanceEvaluationResponse) {
            ActivityInstanceEvaluation|error activity_instance_evaluation_record = createActivityInstanceEvaluationResponse.create_activity_instance_evaluation.cloneWithType(ActivityInstanceEvaluation);
            if(activity_instance_evaluation_record is ActivityInstanceEvaluation) {
                return activity_instance_evaluation_record;
            } else {
                log:printError("Error while processing Application record received", activity_instance_evaluation_record);
                return error("Error while processing Application record received: " + activity_instance_evaluation_record.message() + 
                    ":: Detail: " + activity_instance_evaluation_record.detail().toString());
            }
        } else {
            log:printError("Error while creating application", createActivityInstanceEvaluationResponse);
            return error("Error while creating application: " + createActivityInstanceEvaluationResponse.message() + 
                ":: Detail: " + createActivityInstanceEvaluationResponse.detail().toString());
        }
    }

    resource function get upcoming_events/[int person_id]() returns ActivityInstance[]|error {
        GetUpcomingEventsResponse|graphql:ClientError getUpcomingEventsResponse = globalDataClient->getUpcomingEvents(person_id);
        if(getUpcomingEventsResponse is GetUpcomingEventsResponse) {
            ActivityInstance[]  upcomingEvents = [];
            foreach var upcoming_event_record in getUpcomingEventsResponse.upcoming_events {
                ActivityInstance|error upcoming_event = upcoming_event_record.cloneWithType(ActivityInstance);
                if(upcoming_event is ActivityInstance) {
                    upcomingEvents.push(upcoming_event);
                } else {
                    log:printError("Error while processing Application record received", upcoming_event);
                    return error("Error while processing Application record received: " + upcoming_event.message() + 
                        ":: Detail: " + upcoming_event.detail().toString());
                }
            }

            return upcomingEvents;
            
        } else {
            log:printError("Error while creating application", getUpcomingEventsResponse);
            return error("Error while creating application: " + getUpcomingEventsResponse.message() + 
                ":: Detail: " + getUpcomingEventsResponse.detail().toString());
        }
    }

    resource function get completed_events/[int person_id]() returns ActivityInstance[]|error {
        GetCompletedEventsResponse|graphql:ClientError getCompletedEventsResponse = globalDataClient->getCompletedEvents(person_id);
        if(getCompletedEventsResponse is GetCompletedEventsResponse) {
            ActivityInstance[]  completedEvents = [];
            foreach var completed_event_record in getCompletedEventsResponse.completed_events {
                ActivityInstance|error completed_event = completed_event_record.cloneWithType(ActivityInstance);
                if(completed_event is ActivityInstance) {
                    completedEvents.push(completed_event);
                } else {
                    log:printError("Error while processing Application record received", completed_event);
                    return error("Error while processing Application record received: " + completed_event.message() + 
                        ":: Detail: " + completed_event.detail().toString());
                }
            }

            return completedEvents;
            
        } else {
            log:printError("Error while creating application", getCompletedEventsResponse);
            return error("Error while creating application: " + getCompletedEventsResponse.message() + 
                ":: Detail: " + getCompletedEventsResponse.detail().toString());
        }
    }
    
    resource function get alumni_persons/[int parent_organization_id]() returns Person[]|error {
        GetAlumniPersonsResponse|graphql:ClientError getAlumniPersonsResponse = globalDataClient->getAlumniPersons(parent_organization_id);
        if (getAlumniPersonsResponse is GetAlumniPersonsResponse) {
            Person[] alumni_persons_data = [];
            foreach var alumni_person_data in getAlumniPersonsResponse.alumni_persons {
                Person|error alumni_person_data_record = alumni_person_data.cloneWithType(Person);
                if (alumni_person_data_record is Person) {
                    alumni_persons_data.push(alumni_person_data_record);
                } else {
                    log:printError("Error while processing Application record received", alumni_person_data_record);
                    return error("Error while processing Application record received: " + alumni_person_data_record.message() +
                        ":: Detail: " + alumni_person_data_record.detail().toString());
                }
            }

            return alumni_persons_data;

        } else {
            log:printError("Error while getting application", getAlumniPersonsResponse);
            return error("Error while getting application: " + getAlumniPersonsResponse.message() +
                ":: Detail: " + getAlumniPersonsResponse.detail().toString());
        }
    }

    resource function get alumni_summary/[int alumni_batch_id]() returns Alumni[]|error {
        GetAlumniSummaryResponse|graphql:ClientError getAlumniSummaryResponse = globalDataClient->getAlumniSummary(alumni_batch_id);
        if (getAlumniSummaryResponse is GetAlumniSummaryResponse) {
            Alumni[] alumni_summary_data = [];
            foreach var alumni_summary_data_record in getAlumniSummaryResponse.alumni_summary {
                Alumni|error summary_data_record = alumni_summary_data_record.cloneWithType(Alumni);
                if (summary_data_record is Alumni) {
                    alumni_summary_data.push(summary_data_record);
                } else {
                    log:printError("Error while processing Application record received", summary_data_record);
                    return error("Error while processing Application record received: " + summary_data_record.message() +
                        ":: Detail: " + summary_data_record.detail().toString());
                }
            }

            return alumni_summary_data;

        } else {
            log:printError("Error while getting application", getAlumniSummaryResponse);
            return error("Error while getting application: " + getAlumniSummaryResponse.message() +
                ":: Detail: " + getAlumniSummaryResponse.detail().toString());
        }
    }
    
    resource function post upload_person_profile_picture(http:Request req) returns PersonProfilePicture|ErrorDetail|error {
        
        PersonProfilePicture profile_picture = {};
        PersonProfilePicture profile_picture_details = {};
        int profile_picture_row_id = 0;
        int person_id = 0;
        string person_nic_no = "";
        string profile_picture_uploaded_by = "";

        if (req.getContentType().startsWith("multipart/form-data")) {

            mime:Entity[] bodyParts = check req.getBodyParts();
            string base64EncodedStringProfilePicture = "";

            foreach var part in bodyParts {
                mime:ContentDisposition contentDisposition = part.getContentDisposition();

                if (contentDisposition.name == "profile_picture_details") {

                    json profile_picture_details_in_json = check part.getJson();
                    profile_picture_details = check profile_picture_details_in_json.cloneWithType(PersonProfilePicture);
                    profile_picture_row_id = profile_picture_details?.id ?: 0;
                    person_id = profile_picture_details?.person_id  ?:0;
                    person_nic_no = profile_picture_details?.nic_no ?:"";
                    profile_picture_uploaded_by = profile_picture_details?.uploaded_by ?:"";

                } else if (contentDisposition.name == "profile_picture") {

                    stream<byte[], io:Error?>|mime:ParserError str = part.getByteStream();

                    if str is stream<byte[], io:Error?> {

                        byte[] allBytes = []; // Initialize an empty byte array

                        // Iterate through the stream and collect all chunks
                        error? e = str.forEach(function(byte[] chunk) {
                            array:push(allBytes, ...chunk); // Efficiently append all bytes from chunk
                        });

                        byte[] base64EncodedProfilePicture = <byte[]>(check mime:base64Encode(allBytes));
                        base64EncodedStringProfilePicture = check string:fromBytes(base64EncodedProfilePicture);

                    }
                }

            }

            profile_picture = {
                id: profile_picture_row_id,
                person_id: person_id,
                nic_no: person_nic_no,
                picture: base64EncodedStringProfilePicture,
                uploaded_by: profile_picture_uploaded_by
            };

        }

        UploadPersonProfilePictureResponse|graphql:ClientError uploadPersonProfilePictureResponse = globalDataClient->uploadPersonProfilePicture(profile_picture);
        if (uploadPersonProfilePictureResponse is UploadPersonProfilePictureResponse) {
            PersonProfilePicture|error profile_picture_record = uploadPersonProfilePictureResponse.upload_person_profile_picture.cloneWithType(PersonProfilePicture);
            if (profile_picture_record is PersonProfilePicture) {
                return profile_picture_record;
            } else {
                log:printError("Error while processing Profile picture record received", profile_picture_record);
                 return error("Error while processing Profile picture record received: " + profile_picture_record.message() + 
                    ":: Detail: " + profile_picture_record.detail().toString());
            }
        } else {
            log:printError("Error while creating profile picture", uploadPersonProfilePictureResponse);
            return error("Error while creating profile picture: " + uploadPersonProfilePictureResponse.message() + 
                ":: Detail: " + uploadPersonProfilePictureResponse.detail().toString());
        }
    }
    resource function delete person_profile_picture_by_id/[int id]() returns json|error {
        json|error delete_count = globalDataClient->deletePersonProfilePictureById(id);
        return  delete_count;
    }

    resource function post create_job_post(http:Request req) returns JobPost|error {

        JobPost job_post_details = {};

        if (req.getContentType().startsWith("multipart/form-data")) {

            mime:Entity[] bodyParts = check req.getBodyParts();
            //string base64EncodedStringProfilePicture = "";
            string base64EncodedStringJobPostPicture = "";


            foreach var part in bodyParts {
                mime:ContentDisposition contentDisposition = part.getContentDisposition();

                if (contentDisposition.name == "job_post_details") {

                    json job_post_details_in_json = check part.getJson();
                    job_post_details = check job_post_details_in_json.cloneWithType(JobPost);

                } else if (contentDisposition.name == "job_post_picture") {

                    stream<byte[], io:Error?>|mime:ParserError str = part.getByteStream();

                    if str is stream<byte[], io:Error?> {

                        byte[] allBytes = []; // Initialize an empty byte array

                        // Iterate through the stream and collect all chunks
                        error? e = str.forEach(function(byte[] chunk) {
                            array:push(allBytes, ...chunk); // Efficiently append all bytes from chunk
                        });

                        byte[] base64EncodedJobPostPicture = <byte[]>(check mime:base64Encode(allBytes));
                        base64EncodedStringJobPostPicture = check string:fromBytes(base64EncodedJobPostPicture);
                        job_post_details.job_post_image = base64EncodedStringJobPostPicture;
                        // byte[] base64EncodedProfilePicture = <byte[]>(check mime:base64Encode(allBytes));
                        // base64EncodedStringProfilePicture = check string:fromBytes(base64EncodedProfilePicture);

                    }
                }

            }
        }
        CreateJobPostResponse|graphql:ClientError createJobPostResponse = globalDataClient->createJobPost(job_post_details);
        if (createJobPostResponse is CreateJobPostResponse) {
            JobPost|error job_post_record = createJobPostResponse.create_job_post.cloneWithType(JobPost);
            if (job_post_record is JobPost) {
                return job_post_record;
            } else {
                log:printError("Error while processing Profile picture record received", job_post_record);
                 return error("Error while processing Profile picture record received: " + job_post_record.message() + 
                    ":: Detail: " + job_post_record.detail().toString());
            }
        } else {
            log:printError("Error while creating profile picture", createJobPostResponse);
            return error("Error while creating profile picture: " + createJobPostResponse.message() + 
                ":: Detail: " + createJobPostResponse.detail().toString());
        }
    }

    resource function put update_job_post(http:Request req) returns JobPost|error {

        JobPost update_job_post_details = {};

        if (req.getContentType().startsWith("multipart/form-data")) {

            mime:Entity[] bodyParts = check req.getBodyParts();
            //string base64EncodedStringProfilePicture = "";
            string base64EncodedStringJobPostPicture = "";


            foreach var part in bodyParts {
                mime:ContentDisposition contentDisposition = part.getContentDisposition();

                if (contentDisposition.name == "job_post_details") {

                    json job_post_details_in_json = check part.getJson();
                    update_job_post_details = check job_post_details_in_json.cloneWithType(JobPost);

                } else if (contentDisposition.name == "job_post_picture") {

                    stream<byte[], io:Error?>|mime:ParserError str = part.getByteStream();

                    if str is stream<byte[], io:Error?> {

                        byte[] allBytes = []; // Initialize an empty byte array

                        // Iterate through the stream and collect all chunks
                        error? e = str.forEach(function(byte[] chunk) {
                            array:push(allBytes, ...chunk); // Efficiently append all bytes from chunk
                        });

                        byte[] base64EncodedJobPostPicture = <byte[]>(check mime:base64Encode(allBytes));
                        base64EncodedStringJobPostPicture = check string:fromBytes(base64EncodedJobPostPicture);
                        update_job_post_details.job_post_image = base64EncodedStringJobPostPicture;
                        // byte[] base64EncodedProfilePicture = <byte[]>(check mime:base64Encode(allBytes));
                        // base64EncodedStringProfilePicture = check string:fromBytes(base64EncodedProfilePicture);

                    }
                }

            }
        }
        UpdateJobPostResponse|graphql:ClientError updateJobPostResponse = globalDataClient->updateJobPost(update_job_post_details);
        if (updateJobPostResponse is UpdateJobPostResponse) {
            JobPost|error job_post_record = updateJobPostResponse.update_job_post.cloneWithType(JobPost);
            if (job_post_record is JobPost) {
                return job_post_record;
            } else {
                log:printError("Error while processing Profile picture record received", job_post_record);
                 return error("Error while processing Profile picture record received: " + job_post_record.message() + 
                    ":: Detail: " + job_post_record.detail().toString());
            }
        } else {
            log:printError("Error while creating profile picture", updateJobPostResponse);
            return error("Error while creating profile picture: " + updateJobPostResponse.message() + 
                ":: Detail: " + updateJobPostResponse.detail().toString());
        }
    }

    resource function delete job_post(@http:Payload JobPost jobPost) returns json|error {
        json|error delete_count = globalDataClient->deleteJobPost(jobPost);
        return  delete_count;
    }

    resource function get job_post/[int id]() returns JobPost|error {
        GetJobPostResponse|graphql:ClientError getJobPostResponse = globalDataClient->getJobPost(id);
        if (getJobPostResponse is GetJobPostResponse) {
            JobPost|error job_post_record = getJobPostResponse.job_post.cloneWithType(JobPost);
            if (job_post_record is JobPost) {
                return job_post_record;
            } else {
                log:printError("Error while processing Application record received", job_post_record);
                return error("Error while processing Application record received: " + job_post_record.message() +
                    ":: Detail: " + job_post_record.detail().toString());
            }
        } else {
            log:printError("Error while creating application", getJobPostResponse);
            return error("Error while creating application: " + getJobPostResponse.message() +
                ":: Detail: " + getJobPostResponse.detail().toString());
        }
    }

    resource function get job_posts/[int result_limit]/[int offset]() returns JobPost[]|error {
        GetJobPostsResponse|graphql:ClientError getJobPostsResponse = globalDataClient->getJobPosts(offset,result_limit);
        if (getJobPostsResponse is GetJobPostsResponse) {
            JobPost[] job_posts_data = [];
            foreach var job_post_data_record in getJobPostsResponse.job_posts {
                JobPost|error job_data_record = job_post_data_record.cloneWithType(JobPost);
                if (job_data_record is JobPost) {
                    job_posts_data.push(job_data_record);
                } else {
                    log:printError("Error while processing Application record received", job_data_record);
                    return error("Error while processing Application record received: " + job_data_record.message() +
                        ":: Detail: " + job_data_record.detail().toString());
                }
            }

            return job_posts_data;

        } else {
            log:printError("Error while getting application", getJobPostsResponse);
            return error("Error while getting application: " + getJobPostsResponse.message() +
                ":: Detail: " + getJobPostsResponse.detail().toString());
        }
    }
    
    resource function get job_categories() returns JobCategory[]|error {
        GetJobCategoriesResponse|graphql:ClientError getJobCategoriesResponse = globalDataClient->getJobCategories();
        if (getJobCategoriesResponse is GetJobCategoriesResponse) {
            JobCategory[] jobCategoriesData = [];
            foreach var jobCategory in getJobCategoriesResponse.job_categories {
                JobCategory|error jobCategoryData = jobCategory.cloneWithType(JobCategory);
                if (jobCategoryData is JobCategory) {
                    jobCategoriesData.push(jobCategoryData);
                } else {
                    log:printError("Error while processing Application record received", jobCategoryData);
                    return error("Error while processing Application record received: " + jobCategoryData.message() +
                        ":: Detail: " + jobCategoryData.detail().toString());
                }
            }

            return jobCategoriesData;

        } else {
            log:printError("Error while getting application", getJobCategoriesResponse);
            return error("Error while getting application: " + getJobCategoriesResponse.message() +
                ":: Detail: " + getJobCategoriesResponse.detail().toString());
        }
    }

    //alumni cv feature rest api functions

    //Add cv request rest api function
    resource function post alumni/[int personId]/cv_requests(@http:Payload CvRequest cvRequest) returns CvRequest|ApiInternalServerError|error{
        AddCvRequestResponse|graphql:ClientError addCvRequestResponse = globalDataClient->addCvRequest(cvRequest,personId);
        if(addCvRequestResponse is AddCvRequestResponse) {
            CvRequest|error cvRequestRecord = addCvRequestResponse.addCvRequest.cloneWithType(CvRequest);
            if(cvRequestRecord is CvRequest) {
                return cvRequestRecord;
            } else {
                log:printError("Error adding the CV request", cvRequestRecord);
                return <ApiInternalServerError>{body: { message: "Error adding the CV request" }};
            }
        } else {
            log:printError("Error while adding CV request", addCvRequestResponse);
            return <ApiInternalServerError>{body: { message: "Error adding the CV request" }};
        }
    }

    
    //Get the most recent CV request for an student
    resource function get alumni/[int personId]/cv_requests/last() returns CvRequest|ApiInternalServerError|error {
        FetchLatestCvRequestResponse|graphql:ClientError getLatestCvRequestResponse = globalDataClient->fetchLatestCvRequest(personId);
        if (getLatestCvRequestResponse is FetchLatestCvRequestResponse) {
            CvRequest|error cvRequestRecord = getLatestCvRequestResponse.fetchLatestCvRequest.cloneWithType(CvRequest);
            if (cvRequestRecord is CvRequest) {
                return cvRequestRecord;
            } else {
                //log:printError("Error while getting the cv request",cvRequestRecord);
                return <ApiInternalServerError>{body: { message: "Error while retrieving the CV request" }};
            }
        } else {
            log:printError("Error while getting the cv request", getLatestCvRequestResponse);
            return <ApiInternalServerError>{body: { message: "Error while retrieving the CV request" }};
        }
    }

    //upload the cv
    resource function post alumni/[int personId]/cv(http:Request req) returns PersonCv|ApiErrorResponse|error {

        PersonCv cvDetails = {};

        if (req.getContentType().startsWith("multipart/form-data")) {

            mime:Entity[] bodyParts = check req.getBodyParts();
            string base64EncodedStringCvFile= "";


            foreach var part in bodyParts {
                mime:ContentDisposition contentDisposition = part.getContentDisposition();

                if (contentDisposition.name == "cv_metadata") {

                    json cvMetaDataInJson = check part.getJson();
                    cvDetails = check cvMetaDataInJson.cloneWithType(PersonCv);

                } else if (contentDisposition.name == "cv_file") {

                    stream<byte[], io:Error?>|mime:ParserError str = part.getByteStream();

                    if str is stream<byte[], io:Error?> {

                        byte[] allBytes = []; // Initialize an empty byte array

                        // Iterate through the stream and collect all chunks
                        error? e = str.forEach(function(byte[] chunk) {
                            array:push(allBytes, ...chunk); // Efficiently append all bytes from chunk
                        });

                        byte[] base64EncodedCvFile = <byte[]>(check mime:base64Encode(allBytes));
                        base64EncodedStringCvFile = check string:fromBytes(base64EncodedCvFile);
                        cvDetails.file_content = base64EncodedStringCvFile;

                    }
                }

            }
        }
        UploadCVResponse|graphql:ClientError uploadCVResponse = globalDataClient->uploadCV(cvDetails,personId);
        if (uploadCVResponse is UploadCVResponse) {
            PersonCv|error personCvRecord = uploadCVResponse.uploadCV.cloneWithType(PersonCv);
            if (personCvRecord is PersonCv) {
                return personCvRecord;
            } else {
                log:printError("Error while uploading cv", personCvRecord);
                return <ApiErrorResponse>{body: { message: "Error while uploadnig the CV" }};
            }
        } else {
            log:printError("Error while uploading cv", uploadCVResponse);
            return <ApiErrorResponse>{body: { message: "Error while uploading the CV"}};

        }
    }


    //Fetch the CV of a specific student, which the student can view and download through the mobile app.
    resource function get alumni/[int personId]/cv(string? driveFileId) returns PersonCv|ApiErrorResponse|error {
        FetchPersonCVResponse|graphql:ClientError fetchPersonCVResponse = globalDataClient->fetchPersonCV(personId,driveFileId = ());
        if (fetchPersonCVResponse is FetchPersonCVResponse) {
            PersonCv|error personCvRecord = fetchPersonCVResponse.fetchPersonCV.cloneWithType(PersonCv);
            if (personCvRecord is PersonCv) {
                return personCvRecord;
            } else {
                log:printError("Error while fetching cv", personCvRecord);
                return <ApiErrorResponse>{body: { message: "Error while fetching the CV" }};
            }
        } else {
            log:printError("Error while fetching cv", fetchPersonCVResponse);
            return <ApiErrorResponse>{body: { message: "Error while fetching the CV" }};
        }
    }

   //Create a FCM token for a specific student
    resource function post fcm/[int personId]/token(@http:Payload PersonFcmToken personFcmToken) returns PersonFcmToken|ApiErrorResponse|error {
        AddUserFcmTokenResponse|graphql:ClientError addUserFcmTokenResponse = globalDataClient->addUserFcmToken(personFcmToken,personId);
        if(addUserFcmTokenResponse is AddUserFcmTokenResponse) {
            PersonFcmToken|error personFcmTokenRecord = addUserFcmTokenResponse.saveUserFCMToken.cloneWithType(PersonFcmToken);
            if(personFcmTokenRecord is PersonFcmToken) {
                return personFcmTokenRecord;
            } else {
                log:printError("Error while adding fcm token record", personFcmTokenRecord);
                return <ApiErrorResponse>{body: { message: "Error while adding fcm token record" }};
            }
        } else {
            log:printError("Error while creating application", addUserFcmTokenResponse);
            return <ApiErrorResponse>{body: { message: "Error while adding fcm token record" }};
        }
    }

     //Get FCM token for a specific student
    resource function get fcm/[int personId]/token() returns PersonFcmToken|ApiErrorResponse|error {
        FetchUserFCMTokenResponse|graphql:ClientError fetchUserFCMTokenResponse = globalDataClient->fetchUserFCMToken(personId);
        if (fetchUserFCMTokenResponse is FetchUserFCMTokenResponse) {
            PersonFcmToken|error personFcmTokenRecord = fetchUserFCMTokenResponse.fetchUserFCMToken.cloneWithType(PersonFcmToken);
            if (personFcmTokenRecord is PersonFcmToken) {
                return personFcmTokenRecord;
            } else {
                log:printError("Error while getting the fcm token",personFcmTokenRecord);
                return <ApiErrorResponse>{body: { message: "Error while retrieving the fcm token" }};
            }
        } else {
            log:printError("Error while getting the fcm token", fetchUserFCMTokenResponse);
            return <ApiErrorResponse>{body: { message: "Error while retrieving the fcm token" }};
        }
    }
    
    //Update FCM token for a specific student
    resource function put fcm/[int personId]/token(@http:Payload PersonFcmToken personFcmToken) returns PersonFcmToken|ApiErrorResponse|error {
        UpdateUserFCMTokenResponse|graphql:ClientError updateUserFCMTokenResponse = globalDataClient->updateUserFCMToken(personFcmToken,personId);
        if(updateUserFCMTokenResponse is  UpdateUserFCMTokenResponse) {
            PersonFcmToken|error personFcmTokenRecord = updateUserFCMTokenResponse.updateUserFCMToken.cloneWithType(PersonFcmToken);
            if(personFcmTokenRecord is  PersonFcmToken) {
                return personFcmTokenRecord;
            } else {
                log:printError("Error while updating the fcm token",personFcmTokenRecord);
                return <ApiErrorResponse>{body: { message: "Error while updating the fcm token" }};

            }
        } else {
            log:printError("Error while updating the fcm token",updateUserFCMTokenResponse);
            return <ApiErrorResponse>{body: { message: "Error while updating the fcm token" }};
        }
    }
}
