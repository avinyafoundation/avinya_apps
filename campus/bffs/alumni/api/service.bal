import ballerina/graphql;
import ballerina/http;
import ballerina/log;


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
                    "errorCode": "500"
                };
            }
        } else {
            log:printError("Error while creating application", createAlumniResponse);
            return {
                "message": createAlumniResponse.message().toString(),
                "errorCode": "500"
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

    
}
