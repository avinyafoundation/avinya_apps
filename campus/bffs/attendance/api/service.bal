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
service / on new http:Listener(9091) {

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

    resource function get avinya_types() returns AvinyaType[]|error {
        GetAvinyaTypesResponse|graphql:ClientError getAvinyaTypesResponse = globalDataClient->getAvinyaTypes();
        if(getAvinyaTypesResponse is GetAvinyaTypesResponse) {
            AvinyaType[] avinyaTypes = [];
            foreach var avinya_type in getAvinyaTypesResponse.avinya_types {
                AvinyaType|error avinyaType = avinya_type.cloneWithType(AvinyaType);
                if(avinyaType is AvinyaType) {
                    avinyaTypes.push(avinyaType);
                } else {
                    log:printError("Error while processing Application record received", avinyaType);
                    return error("Error while processing Application record received: " + avinyaType.message() + 
                        ":: Detail: " + avinyaType.detail().toString());
                }
            }

            return avinyaTypes;
            
        } else {
            log:printError("Error while getting application", getAvinyaTypesResponse);
            return error("Error while getting application: " + getAvinyaTypesResponse.message() + 
                ":: Detail: " + getAvinyaTypesResponse.detail().toString());
        }
    }

    resource function post avinya_types (@http:Payload AvinyaType avinyaType) returns AvinyaType|error {
        CreateAvinyaTypeResponse|graphql:ClientError createAvinyaTypeResponse = globalDataClient->createAvinyaType(avinyaType);
        if(createAvinyaTypeResponse is CreateAvinyaTypeResponse) {
            AvinyaType|error avinya_type_record = createAvinyaTypeResponse.add_avinya_type.cloneWithType(AvinyaType);
            if(avinya_type_record is AvinyaType) {
                return avinya_type_record;
            } else {
                log:printError("Error while processing Application record received", avinya_type_record);
                return error("Error while processing Application record received: " + avinya_type_record.message() + 
                    ":: Detail: " + avinya_type_record.detail().toString());
            }
        } else {
            log:printError("Error while creating application", createAvinyaTypeResponse);
            return error("Error while creating application: " + createAvinyaTypeResponse.message() + 
                ":: Detail: " + createAvinyaTypeResponse.detail().toString());
        }
    }

    resource function put avinya_types (@http:Payload AvinyaType avinyaType) returns AvinyaType|error {
        UpdateAvinyaTypeResponse|graphql:ClientError updateAvinyaTypeResponse = globalDataClient->updateAvinyaType(avinyaType);
        if(updateAvinyaTypeResponse is UpdateAvinyaTypeResponse) {
            AvinyaType|error avinya_type_record = updateAvinyaTypeResponse.update_avinya_type.cloneWithType(AvinyaType);
            if(avinya_type_record is AvinyaType) {
                return avinya_type_record;
            } else {
                log:printError("Error while processing Application record received", avinya_type_record);
                return error("Error while processing Application record received: " + avinya_type_record.message() + 
                    ":: Detail: " + avinya_type_record.detail().toString());
            }
        } else {
            log:printError("Error while creating application", updateAvinyaTypeResponse);
            return error("Error while creating application: " + updateAvinyaTypeResponse.message() + 
                ":: Detail: " + updateAvinyaTypeResponse.detail().toString());
        }
    }

    resource function get activity/[string name]() returns Activity|error {
        GetActivityResponse|graphql:ClientError getActivityResponse = globalDataClient->getActivity(name);
        if(getActivityResponse is GetActivityResponse) {
            Activity|error activity_record = getActivityResponse.activity.cloneWithType(Activity);
            if(activity_record is Activity) {
                return activity_record;
            } else {
                log:printError("Error while processing Application record received", activity_record);
                return error("Error while processing Application record received: " + activity_record.message() + 
                    ":: Detail: " + activity_record.detail().toString());
            }
        } else {
            log:printError("Error while creating application", getActivityResponse);
            return error("Error while creating application: " + getActivityResponse.message() + 
                ":: Detail: " + getActivityResponse.detail().toString());
        }
    }

    resource function post activity_attendance (@http:Payload ActivityParticipantAttendance activityAttendance) returns ActivityParticipantAttendance|error {
        AddActivityAttendanceResponse|graphql:ClientError addActivityAttendanceResponse = globalDataClient->addActivityAttendance(activityAttendance);
        if(addActivityAttendanceResponse is AddActivityAttendanceResponse) {
            ActivityParticipantAttendance|error attendance_record = addActivityAttendanceResponse.add_attendance.cloneWithType(ActivityParticipantAttendance);
            if(attendance_record is ActivityParticipantAttendance) {
                return attendance_record;
            } else {
                log:printError("Error while processing Application record received", attendance_record);
                return error("Error while processing Application record received: " + attendance_record.message() + 
                    ":: Detail: " + attendance_record.detail().toString());
            }
        } else {
            log:printError("Error while creating application", addActivityAttendanceResponse);
            return error("Error while creating application: " + addActivityAttendanceResponse.message() + 
                ":: Detail: " + addActivityAttendanceResponse.detail().toString());
        }
    }

    resource function delete activity_attendance/[int id]() returns json|error {
        json|error delete_count = globalDataClient->deleteActivityAttendance(id);
        return  delete_count;
    }

    resource function delete person_activity_attendance/[int person_id]() returns json|error {
        json|error delete_count = globalDataClient->deletePersonActivityAttendance(person_id);
        return  delete_count;
    }

    resource function get activity_instances_today/[int activity_id]() returns ActivityInstance[]|error {
        GetActivityInstancesTodayResponse|graphql:ClientError getActivityInstancesTodayResponse = globalDataClient->getActivityInstancesToday(activity_id);
        if(getActivityInstancesTodayResponse is GetActivityInstancesTodayResponse) {
            ActivityInstance[] activityInstances = [];
            foreach var activity_instance in getActivityInstancesTodayResponse.activity_instances_today {
                ActivityInstance|error activityInstance = activity_instance.cloneWithType(ActivityInstance);
                if(activityInstance is ActivityInstance) {
                    activityInstances.push(activityInstance);
                } else {
                    log:printError("Error while processing Application record received", activityInstance);
                    return error("Error while processing Application record received: " + activityInstance.message() + 
                        ":: Detail: " + activityInstance.detail().toString());
                }
            }

            return activityInstances;
            
        } else {
            log:printError("Error while creating application", getActivityInstancesTodayResponse);
            return error("Error while creating application: " + getActivityInstancesTodayResponse.message() + 
                ":: Detail: " + getActivityInstancesTodayResponse.detail().toString());
        }
    }

    resource function get class_attendance_today/[int organization_id]/[int activity_id]() returns ActivityParticipantAttendance[]|error {
        GetClassAttendanceTodayResponse|graphql:ClientError getClassAttendanceTodayResponse = globalDataClient->getClassAttendanceToday(organization_id, activity_id);
        if(getClassAttendanceTodayResponse is GetClassAttendanceTodayResponse) {
            ActivityParticipantAttendance[] activityParticipantAttendances = [];
            foreach var attendace_record in getClassAttendanceTodayResponse.class_attendance_today {
                ActivityParticipantAttendance|error activityParticipantAttendance = attendace_record.cloneWithType(ActivityParticipantAttendance);
                if(activityParticipantAttendance is ActivityParticipantAttendance) {
                    activityParticipantAttendances.push(activityParticipantAttendance);
                } else {
                    log:printError("Error while processing Application record received", activityParticipantAttendance);
                    return error("Error while processing Application record received: " + activityParticipantAttendance.message() + 
                        ":: Detail: " + activityParticipantAttendance.detail().toString());
                }
            }

            return activityParticipantAttendances;
            
        } else {
            log:printError("Error while creating application", getClassAttendanceTodayResponse);
            return error("Error while creating application: " + getClassAttendanceTodayResponse.message() + 
                ":: Detail: " + getClassAttendanceTodayResponse.detail().toString());
        }
    }

    resource function get person_attendance_today/[int person_id]/[int activity_id]() returns ActivityParticipantAttendance[]|error {
        GetPersonAttendanceTodayResponse|graphql:ClientError getPersonAttendanceTodayResponse = globalDataClient->getPersonAttendanceToday(person_id, activity_id);
        if(getPersonAttendanceTodayResponse is GetPersonAttendanceTodayResponse) {
            ActivityParticipantAttendance[] activityParticipantAttendances = [];
            foreach var attendace_record in getPersonAttendanceTodayResponse.person_attendance_today {
                ActivityParticipantAttendance|error activityParticipantAttendance = attendace_record.cloneWithType(ActivityParticipantAttendance);
                if(activityParticipantAttendance is ActivityParticipantAttendance) {
                    activityParticipantAttendances.push(activityParticipantAttendance);
                } else {
                    log:printError("Error while processing Application record received", activityParticipantAttendance);
                    return error("Error while processing Application record received: " + activityParticipantAttendance.message() + 
                        ":: Detail: " + activityParticipantAttendance.detail().toString());
                }
            }

            return activityParticipantAttendances;
            
        } else {
            log:printError("Error while creating application", getPersonAttendanceTodayResponse);
            return error("Error while creating application: " + getPersonAttendanceTodayResponse.message() + 
                ":: Detail: " + getPersonAttendanceTodayResponse.detail().toString());
        }
    }

    resource function get class_attendance_report/[int organization_id]/[int activity_id]/[int result_limit]() returns ActivityParticipantAttendance[]|error {
        GetClassAttendanceReportResponse|graphql:ClientError getClassAttendanceReportResponse = globalDataClient->getClassAttendanceReport(organization_id, activity_id, result_limit);
        if(getClassAttendanceReportResponse is GetClassAttendanceReportResponse) {
            ActivityParticipantAttendance[] activityParticipantAttendances = [];
            foreach var attendace_record in getClassAttendanceReportResponse.class_attendance_report {
                ActivityParticipantAttendance|error activityParticipantAttendance = attendace_record.cloneWithType(ActivityParticipantAttendance);
                if(activityParticipantAttendance is ActivityParticipantAttendance) {
                    activityParticipantAttendances.push(activityParticipantAttendance);
                } else {
                    log:printError("Error while processing Application record received", activityParticipantAttendance);
                    return error("Error while processing Application record received: " + activityParticipantAttendance.message() + 
                        ":: Detail: " + activityParticipantAttendance.detail().toString());
                }
            }

            return activityParticipantAttendances;
            
        } else {
            log:printError("Error while creating application", getClassAttendanceReportResponse);
            return error("Error while creating application: " + getClassAttendanceReportResponse.message() + 
                ":: Detail: " + getClassAttendanceReportResponse.detail().toString());
        }
    }

      resource function get class_attendance_report_date/[int organization_id]/[int activity_id]/[string from_date]/[string to_date]() returns ActivityParticipantAttendance[]|error {
        GetClassAttendanceReportResponse|graphql:ClientError getClassAttendanceReportResponse = globalDataClient->getClassAttendanceReportByDate(organization_id, activity_id, from_date, to_date);
        if(getClassAttendanceReportResponse is GetClassAttendanceReportResponse) {
            ActivityParticipantAttendance[] activityParticipantAttendances = [];
            foreach var attendace_record in getClassAttendanceReportResponse.class_attendance_report {
                ActivityParticipantAttendance|error activityParticipantAttendance = attendace_record.cloneWithType(ActivityParticipantAttendance);
                if(activityParticipantAttendance is ActivityParticipantAttendance) {
                    activityParticipantAttendances.push(activityParticipantAttendance);
                } else {
                    log:printError("Error while processing Application record received", activityParticipantAttendance);
                    return error("Error while processing Application record received: " + activityParticipantAttendance.message() + 
                        ":: Detail: " + activityParticipantAttendance.detail().toString());
                }
            }

            return activityParticipantAttendances;
            
        } else {
            log:printError("Error while creating application", getClassAttendanceReportResponse);
            return error("Error while creating application: " + getClassAttendanceReportResponse.message() + 
                ":: Detail: " + getClassAttendanceReportResponse.detail().toString());
        }
    }

    resource function get class_attendance_report_by_parent_org/[int parent_organization_id]/[int activity_id]/[string from_date]/[string to_date]() returns ActivityParticipantAttendance[]|error {
        GetClassAttendanceReportResponse|graphql:ClientError getClassAttendanceReportResponse = globalDataClient->getClassAttendanceReportByParentOrg(parent_organization_id, activity_id, from_date, to_date);
        if(getClassAttendanceReportResponse is GetClassAttendanceReportResponse) {
            ActivityParticipantAttendance[] activityParticipantAttendances = [];
            foreach var attendace_record in getClassAttendanceReportResponse.class_attendance_report {
                ActivityParticipantAttendance|error activityParticipantAttendance = attendace_record.cloneWithType(ActivityParticipantAttendance);
                if(activityParticipantAttendance is ActivityParticipantAttendance) {
                    activityParticipantAttendances.push(activityParticipantAttendance);
                } else {
                    log:printError("Error while processing Application record received", activityParticipantAttendance);
                    return error("Error while processing Application record received: " + activityParticipantAttendance.message() + 
                        ":: Detail: " + activityParticipantAttendance.detail().toString());
                }
            }

            return activityParticipantAttendances;
            
        } else {
            log:printError("Error while creating application", getClassAttendanceReportResponse);
            return error("Error while creating application: " + getClassAttendanceReportResponse.message() + 
                ":: Detail: " + getClassAttendanceReportResponse.detail().toString());
        }
    }

    resource function get person_attendance_report/[int person_id]/[int activity_id]/[int result_limit]() returns ActivityParticipantAttendance[]|error {
        GetPersonAttendanceReportResponse|graphql:ClientError getPersonAttendanceReportResponse = globalDataClient->getPersonAttendanceReport(person_id, activity_id, result_limit);
        if(getPersonAttendanceReportResponse is GetPersonAttendanceReportResponse) {
            ActivityParticipantAttendance[] activityParticipantAttendances = [];
            foreach var attendace_record in getPersonAttendanceReportResponse.person_attendance_report {
                ActivityParticipantAttendance|error activityParticipantAttendance = attendace_record.cloneWithType(ActivityParticipantAttendance);
                if(activityParticipantAttendance is ActivityParticipantAttendance) {
                    activityParticipantAttendances.push(activityParticipantAttendance);
                } else {
                    log:printError("Error while processing Application record received", activityParticipantAttendance);
                    return error("Error while processing Application record received: " + activityParticipantAttendance.message() + 
                        ":: Detail: " + activityParticipantAttendance.detail().toString());
                }
            }

            return activityParticipantAttendances;
            
        } else {
            log:printError("Error while creating application", getPersonAttendanceReportResponse);
            return error("Error while creating application: " + getPersonAttendanceReportResponse.message() + 
                ":: Detail: " + getPersonAttendanceReportResponse.detail().toString());
        }
    }

    resource function post evaluations (@http:Payload Evaluation[] evaluations) returns json|error {
        json|graphql:ClientError createEvaluationResponse = globalDataClient->createEvaluations(evaluations);
        if(createEvaluationResponse is json) {
            log:printInfo("Evaluations created successfully: " + createEvaluationResponse.toString());
            return createEvaluationResponse;
        } else {
            log:printError("Error while creating evaluation", createEvaluationResponse);
            return error("Error while creating evaluation: " + createEvaluationResponse.message() + 
                ":: Detail: " + createEvaluationResponse.detail().toString());
        }
    }

    resource function put evaluations (@http:Payload Evaluation evaluation) returns Evaluation|error {
        UpdateEvaluationsResponse|graphql:ClientError updateEvaluationResponse = globalDataClient->updateEvaluations(evaluation);
        if(updateEvaluationResponse is UpdateEvaluationsResponse) {
            Evaluation|error evaluation_record = updateEvaluationResponse.update_evaluation.cloneWithType(Evaluation);
            if(evaluation_record is Evaluation) {
                return evaluation_record;
            }
            else {
                return error("Error while processing Application record received: " + evaluation_record.message() + 
                    ":: Detail: " + evaluation_record.detail().toString());
            }
        } else {
            log:printError("Error while creating evaluation", updateEvaluationResponse);
            return error("Error while creating evaluation: " + updateEvaluationResponse.message() + 
                ":: Detail: " + updateEvaluationResponse.detail().toString());
        }
    }

    resource function delete evaluations/[int id]() returns json|error {
        json|error delete_count = globalDataClient->deleteEvaluation(id);
        return  delete_count;
    }

    resource function get activity_evaluations/[int activity_id]() returns Evaluation[]|error {
        GetActivityEvaluationsResponse|graphql:ClientError getActivityEvaluationsResponse = globalDataClient->getActivityEvaluations(activity_id);
        if(getActivityEvaluationsResponse is GetActivityEvaluationsResponse) {
            Evaluation[] evaluations = [];
            foreach var evaluation_record in getActivityEvaluationsResponse.activity_evaluations {
                Evaluation|error evaluation = evaluation_record.cloneWithType(Evaluation);
                if(evaluation is Evaluation) {
                    evaluations.push(evaluation);
                } else {
                    log:printError("Error while processing Application record received", evaluation);
                    return error("Error while processing Application record received: " + evaluation.message() + 
                        ":: Detail: " + evaluation.detail().toString());
                }
            }

            return evaluations;
            
        } else {
            log:printError("Error while getting evaluations", getActivityEvaluationsResponse);
            return error("Error while getting evaluations: " + getActivityEvaluationsResponse.message() + 
                ":: Detail: " + getActivityEvaluationsResponse.detail().toString());
        }
    }

    resource function get activity_instance_evaluations/[int activity_instancce_id]() returns Evaluation[]|error {
        GetActivityInstanceEvaluationsResponse|graphql:ClientError getActivityInstanceEvaluationsResponse = globalDataClient->getActivityInstanceEvaluations(activity_instancce_id);
        if(getActivityInstanceEvaluationsResponse is GetActivityInstanceEvaluationsResponse) {
            Evaluation[] evaluations = [];
            foreach var evaluation_record in getActivityInstanceEvaluationsResponse.activity_instance_evaluations {
                Evaluation|error evaluation = evaluation_record.cloneWithType(Evaluation);
                if(evaluation is Evaluation) {
                    evaluations.push(evaluation);
                } else {
                    log:printError("Error while processing Application record received", evaluation);
                    return error("Error while processing Application record received: " + evaluation.message() + 
                        ":: Detail: " + evaluation.detail().toString());
                }
            }

            return evaluations;
            
        } else {
            log:printError("Error while getting evaluations", getActivityInstanceEvaluationsResponse);
            return error("Error while getting evaluations: " + getActivityInstanceEvaluationsResponse.message() + 
                ":: Detail: " + getActivityInstanceEvaluationsResponse.detail().toString());
        }
    }
    
}
