import ballerina/http;
import ballerina/graphql;
import ballerina/log;



public function initClientConfig() returns ConnectionConfig{
    ConnectionConfig _clientConig = {};
    if (GLOBAL_DATA_USE_AUTH) {
        _clientConig.oauth2ClientCredentialsGrantConfig =  {
            tokenUrl: CHOREO_TOKEN_URL,
            clientId:GLOBAL_DATA_CLIENT_ID,
            clientSecret:GLOBAL_DATA_CLIENT_SECRET
        };
    } else { 
        _clientConig = {};
    }
    return _clientConig;
}


final GraphqlClient globalDataClient = check new (GLOBAL_DATA_API_URL,
    config = initClientConfig()
);

# A service representing a network-accessible API
# bound to port `9091`.
@http:ServiceConfig {
    cors: {
        allowOrigins: ["*"]
    }
}

service / on new http:Listener(9092) {

    # A resource for generating greetings
    # + name - the input string name
    # + return - string name with hello message or error
    resource function get greeting(string name) returns string|error {
        // Send a response back to the caller.
        if name is "" {
            return error("name should not be empty!");
        }
        return "Hello, " + name;
    }


    resource function get pcti_activity_notes(int pcti_activity_id) returns Evaluation[]|error {
        log:printInfo("Retrieving Pcti Activity Notes for Pcti Activity " + pcti_activity_id.toString());
        GetPctiActivityNotesResponse|graphql:ClientError getPctiActivityNotesResponse = globalDataClient->getPctiActivityNotes(pcti_activity_id);
        if (getPctiActivityNotesResponse is GetPctiActivityNotesResponse) {
            Evaluation[] evaluations = [];
            foreach var pctiActivityNote in getPctiActivityNotesResponse.pcti_activity_notes {
                Evaluation|error evaluation = pctiActivityNote.cloneWithType(Evaluation);
                if (evaluation is Evaluation) {
                    evaluations.push(evaluation);
                } else {
                    log:printError("Error while processing Pcti Activity Note record received", evaluation);
                    return error("Error while processing Pcti Activity Note record received: " + evaluation.message() + 
                        ":: Detail: " + evaluation.detail().toString());
                }
            }
            return evaluations;
        } else {
            log:printError("Error while getting Pcti Activity Notes", getPctiActivityNotesResponse);
            return error("Error while getting Pcti Activity Notes: " + getPctiActivityNotesResponse.message() + 
                ":: Detail: " + getPctiActivityNotesResponse.detail().toString());
        }
    }

    resource function get pcti_instance_notes(int pcti_instance_id) returns Evaluation[]|error {
        GetPctiInstanceNotesResponse|graphql:ClientError getPctiInstanceNotesResponse = globalDataClient->getPctiInstanceNotes(pcti_instance_id);
        if (getPctiInstanceNotesResponse is GetPctiInstanceNotesResponse) {
            Evaluation[] evaluations = [];
            foreach var pctiInstanceNote in getPctiInstanceNotesResponse.pcti_instance_notes {
                Evaluation|error evaluation = pctiInstanceNote.cloneWithType(Evaluation);
                if (evaluation is Evaluation) {
                    evaluations.push(evaluation);
                } else {
                    log:printError("Error while processing Pcti Instance Note record received", evaluation);
                    return error("Error while processing Pcti Instance Note record received: " + evaluation.message() + 
                        ":: Detail: " + evaluation.detail().toString());
                }
            }
            return evaluations;
        } else {
            log:printError("Error while getting Pcti Instance Notes", getPctiInstanceNotesResponse);
            return error("Error while getting Pcti Instance Notes: " + getPctiInstanceNotesResponse.message() + 
                ":: Detail: " + getPctiInstanceNotesResponse.detail().toString());
        }
    }

    resource function get pcti_activity(string project_activity_name, string class_activity_name) returns Activity|error?{
        GetPctiActivityResponse|graphql:ClientError getPctiActivityResponse = globalDataClient->getPctiActivity(project_activity_name, class_activity_name);
        if (getPctiActivityResponse is GetPctiActivityResponse) {
            Activity|error activity = getPctiActivityResponse.pcti_activity.cloneWithType(Activity);
            if (activity is Activity) {
                return activity;
            } else {
                log:printError("Error while processing Pcti Activity record received", activity);
                return error("Error while processing Pcti Activity record received: " + activity.message() + 
                    ":: Detail: " + activity.detail().toString());
            }
        } else {
            log:printError("Error while getting Pcti Activity", getPctiActivityResponse);
            return error("Error while getting Pcti Activity: " + getPctiActivityResponse.message() + 
                ":: Detail: " + getPctiActivityResponse.detail().toString());
        }
    }

    resource function get activity(string? name = (), int? id = ()) returns Activity|error {
        GetActivityResponse|graphql:ClientError getActivityResponse = globalDataClient->getActivity(name, id);
        if (getActivityResponse is GetActivityResponse) {
            Activity|error activity = getActivityResponse.activity.cloneWithType(Activity);
            if (activity is Activity) {
                return activity;
            } else {
                log:printError("Error while processing Activity record received", activity);
                return error("Error while processing Activity record received: " + activity.message() + 
                    ":: Detail: " + activity.detail().toString());
            }
        } else {
            log:printError("Error while getting Activity", getActivityResponse);
            return error("Error while getting Activity: " + getActivityResponse.message() + 
                ":: Detail: " + getActivityResponse.detail().toString());
        }
    }

    resource function get person(string? name = (), int? id = ()) returns Person|error {
        GetPersonResponse|graphql:ClientError getPersonResponse = globalDataClient->getPerson(name, id);
        if (getPersonResponse is GetPersonResponse) {
            Person|error person = getPersonResponse.person.cloneWithType(Person);
            if (person is Person) {
                return person;
            } else {
                log:printError("Error while processing Person record received", person);
                return error("Error while processing Person record received: " + person.message() + 
                    ":: Detail: " + person.detail().toString());
            }
        } else {
            log:printError("Error while getting Person", getPersonResponse);
            return error("Error while getting Person: " + getPersonResponse.message() + 
                ":: Detail: " + getPersonResponse.detail().toString());
        }
    }


    resource function post activity_instance(@http:Payload ActivityInstance activityInstance) returns ActivityInstance|error {
        AddActivityInstanceResponse|graphql:ClientError addActivityInstanceResponse = globalDataClient->addActivityInstance(activityInstance);
        if (addActivityInstanceResponse is AddActivityInstanceResponse) {
            ActivityInstance|error activityInstanceRecord = addActivityInstanceResponse.add_activity_instance.cloneWithType(ActivityInstance);
            if (activityInstanceRecord is ActivityInstance) {
                return activityInstanceRecord;
            } else {
                log:printError("Error while processing Activity Instance record received", activityInstanceRecord);
                return error("Error while processing Activity Instance record received: " + activityInstanceRecord.message() + 
                    ":: Detail: " + activityInstanceRecord.detail().toString());
            }
        } else {
            log:printError("Error while adding Activity Instance", addActivityInstanceResponse);
            return error("Error while adding Activity Instance: " + addActivityInstanceResponse.message() + 
                ":: Detail: " + addActivityInstanceResponse.detail().toString());
        }
    }


    resource function post pcti_notes(@http:Payload Evaluation pcti_note) returns Evaluation|error {
        AddPctiNotesResponse|graphql:ClientError addPctiNotesResponse = globalDataClient->addPctiNotes(pcti_note);
        if (addPctiNotesResponse is AddPctiNotesResponse) {
            Evaluation|error evaluationRecord = addPctiNotesResponse.add_pcti_notes.cloneWithType(Evaluation);
            if (evaluationRecord is Evaluation) {
                return evaluationRecord;
            } else {
                log:printError("Error while processing Evaluation record received", evaluationRecord);
                return error("Error while processing Evaluation record received: " + evaluationRecord.message() + 
                    ":: Detail: " + evaluationRecord.detail().toString());
            }
        } else {
            log:printError("Error while adding PCTI notes", addPctiNotesResponse);
            return error("Error while adding PCTI notes: " + addPctiNotesResponse.message() + 
                ":: Detail: " + addPctiNotesResponse.detail().toString());
        }
    }

    resource function get pcti_participant_activities(int person_id) returns Activity[]|error {
        GetPctiParticipantActivitiesResponse|graphql:ClientError getPctiParticipantActivitiesResponse = globalDataClient->getPctiParticipantActivities(person_id);
        if (getPctiParticipantActivitiesResponse is GetPctiParticipantActivitiesResponse) {
            Activity[] activities = [];
            foreach var pctiParticipantActivity in getPctiParticipantActivitiesResponse.pcti_participant_activities {
                Activity|error activity = pctiParticipantActivity.cloneWithType(Activity);
                if (activity is Activity) {
                    activities.push(activity);
                } else {
                    log:printError("Error while processing Pcti Participant Activity record received", activity);
                    return error("Error while processing Pcti Participant Activity record received: " + activity.message() + 
                        ":: Detail: " + activity.detail().toString());
                }
            }
            return activities;
        } else {
            log:printError("Error while getting Pcti Participant Activities", getPctiParticipantActivitiesResponse);
            return error("Error while getting Pcti Participant Activities: " + getPctiParticipantActivitiesResponse.message() + 
                ":: Detail: " + getPctiParticipantActivitiesResponse.detail().toString());
        }
    }

    resource function get activity_instances_today(int activity_id) returns ActivityInstance[]|error {
        GetPctiActivityInstancesTodayResponse|graphql:ClientError getPctiActivityInstancesTodayResponse = globalDataClient->getPctiActivityInstancesToday(activity_id);
        if (getPctiActivityInstancesTodayResponse is GetPctiActivityInstancesTodayResponse) {
            ActivityInstance[] activityInstances = [];
            foreach var pctiActivityInstance in getPctiActivityInstancesTodayResponse.activity_instances_today {
                ActivityInstance|error activityInstance = pctiActivityInstance.cloneWithType(ActivityInstance);
                if (activityInstance is ActivityInstance) {
                    activityInstances.push(activityInstance);
                } else {
                    log:printError("Error while processing Pcti Activity Instance record received", activityInstance);
                    return error("Error while processing Pcti Activity Instance record received: " + activityInstance.message() + 
                        ":: Detail: " + activityInstance.detail().toString());
                }
            }
            return activityInstances;
        } else {
            log:printError("Error while getting Pcti Activity Instances Today", getPctiActivityInstancesTodayResponse);
            return error("Error while getting Pcti Activity Instances Today: " + getPctiActivityInstancesTodayResponse.message() + 
                ":: Detail: " + getPctiActivityInstancesTodayResponse.detail().toString());
        }
    }

    resource function get pcti_activities() returns Activity[]|error {
        GetPctiActivitiesResponse|graphql:ClientError getPctiActivitiesResponse = globalDataClient->getPctiActivities();
        if (getPctiActivitiesResponse is GetPctiActivitiesResponse) {
            Activity[] activities = [];
            foreach var pctiActivity in getPctiActivitiesResponse.pcti_activities {
                Activity|error activity = pctiActivity.cloneWithType(Activity);
                if (activity is Activity) {
                    activities.push(activity);
                } else {
                    log:printError("Error while processing Pcti Activity record received", activity);
                    return error("Error while processing Pcti Activity record received: " + activity.message() + 
                        ":: Detail: " + activity.detail().toString());
                }
            }
            return activities;
        } else {
            log:printError("Error while getting Pcti Activities", getPctiActivitiesResponse);
            return error("Error while getting Pcti Activities: " + getPctiActivitiesResponse.message() + 
                ":: Detail: " + getPctiActivitiesResponse.detail().toString());
        }
    }

    resource function get activity_instances_future(int activity_id) returns ActivityInstance[]|error {
        GetActivityInstancesFutureResponse|graphql:ClientError getActivityInstancesFutureResponse = globalDataClient->getActivityInstancesFuture(activity_id);
        if (getActivityInstancesFutureResponse is GetActivityInstancesFutureResponse) {
            ActivityInstance[] activityInstances = [];
            foreach var activityInstance in getActivityInstancesFutureResponse.activity_instances_future {
                ActivityInstance|error activityInstanceRecord = activityInstance.cloneWithType(ActivityInstance);
                if (activityInstanceRecord is ActivityInstance) {
                    activityInstances.push(activityInstanceRecord);
                } else {
                    log:printError("Error while processing Activity Instance record received", activityInstanceRecord);
                    return error("Error while processing Activity Instance record received: " + activityInstanceRecord.message() + 
                        ":: Detail: " + activityInstanceRecord.detail().toString());
                }
            }
            return activityInstances;
        } else {
            log:printError("Error while getting Activity Instances Future", getActivityInstancesFutureResponse);
            return error("Error while getting Activity Instances Future: " + getActivityInstancesFutureResponse.message() + 
                ":: Detail: " + getActivityInstancesFutureResponse.detail().toString());
        }
    }

    resource function get available_teachers(int activity_instance_id) returns Person[]|error? {
        GetAvailableTeachersResponse|graphql:ClientError getAvailableTeachersResponse = globalDataClient->getAvailableTeachers(activity_instance_id);
        if (getAvailableTeachersResponse is GetAvailableTeachersResponse) {
            Person[] persons = [];
            foreach var availableTeacher in getAvailableTeachersResponse.available_teachers {
                Person|error person = availableTeacher.cloneWithType(Person);
                if (person is Person) {
                    persons.push(person);
                } else {
                    log:printError("Error while processing Available Teacher record received", person);
                    return error("Error while processing Available Teacher record received: " + person.message() + 
                        ":: Detail: " + person.detail().toString());
                }
            }
            return persons;
        } else {
            log:printError("Error while getting Available Teachers", getAvailableTeachersResponse);
            return error("Error while getting Available Teachers: " + getAvailableTeachersResponse.message() + 
                ":: Detail: " + getAvailableTeachersResponse.detail().toString());
        }
    }

    resource function post activity_participant(@http:Payload ActivityParticipant activity_participant) returns ActivityParticipant|error {
        AddActivityParticipantResponse|graphql:ClientError addActivityParticipantResponse = globalDataClient->addActivityParticipant(activity_participant);
        if (addActivityParticipantResponse is AddActivityParticipantResponse) {
            ActivityParticipant|error activityParticipant = addActivityParticipantResponse.add_activity_participant.cloneWithType(ActivityParticipant);
            if (activityParticipant is ActivityParticipant) {
                return activityParticipant;
            } else {
                log:printError("Error while processing Activity Participant record received", activityParticipant);
                return error("Error while processing Activity Participant record received: " + activityParticipant.message() + 
                    ":: Detail: " + activityParticipant.detail().toString());
            }
        } else {
            log:printError("Error while adding Activity Participant", addActivityParticipantResponse);
            return error("Error while adding Activity Participant: " + addActivityParticipantResponse.message() + 
                ":: Detail: " + addActivityParticipantResponse.detail().toString());
        }
    }

}
