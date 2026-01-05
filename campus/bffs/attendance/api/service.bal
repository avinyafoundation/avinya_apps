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

    resource function get attendance_report_by_batch/[int batch_id]/[int activity_id]/[string from_date]/[string to_date]() returns ActivityParticipantAttendance[]|error {
        GetClassAttendanceReportResponse|graphql:ClientError getAttendanceReportByBatchResponse = globalDataClient->getAttendanceReportByBatch(batch_id, activity_id, from_date, to_date);
        if(getAttendanceReportByBatchResponse is GetClassAttendanceReportResponse) {
            ActivityParticipantAttendance[] activityParticipantAttendances = [];
            foreach var attendace_record in getAttendanceReportByBatchResponse.class_attendance_report {
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
            log:printError("Error while creating application", getAttendanceReportByBatchResponse);
            return error("Error while creating application: " + getAttendanceReportByBatchResponse.message() + 
                ":: Detail: " + getAttendanceReportByBatchResponse.detail().toString());
        }
    }

    resource function get late_attendance_report_date/[int organization_id]/[int activity_id]/[string from_date]/[string to_date]() returns ActivityParticipantAttendance[]|error {
        GetLateAttendanceReportResponse|graphql:ClientError getLateAttendanceReportResponse = globalDataClient->getLateAttendanceReportByDate(organization_id, activity_id, from_date, to_date);
        if(getLateAttendanceReportResponse is GetLateAttendanceReportResponse) {
            ActivityParticipantAttendance[] activityParticipantAttendances = [];
            foreach var attendace_record in getLateAttendanceReportResponse.late_attendance_report {
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
            log:printError("Error while creating application", getLateAttendanceReportResponse);
            return error("Error while creating application: " + getLateAttendanceReportResponse.message() + 
                ":: Detail: " + getLateAttendanceReportResponse.detail().toString());
        }
    }

    resource function get late_attendance_report_by_parent_org/[int parent_organization_id]/[int activity_id]/[string from_date]/[string to_date]() returns ActivityParticipantAttendance[]|error {
        GetLateAttendanceReportResponseForParentOrg|graphql:ClientError getLateAttendanceReportResponse = globalDataClient->getLateAttendanceReportByParentOrg(parent_organization_id, activity_id, from_date, to_date);
        if(getLateAttendanceReportResponse is GetLateAttendanceReportResponseForParentOrg) {
            ActivityParticipantAttendance[] activityParticipantAttendances = [];
            foreach var attendace_record in getLateAttendanceReportResponse.late_attendance_report {
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
            log:printError("Error while creating application", getLateAttendanceReportResponse);
            return error("Error while creating application: " + getLateAttendanceReportResponse.message() + 
                ":: Detail: " + getLateAttendanceReportResponse.detail().toString());
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

    resource function get duty_participants/[int organization_id]() returns DutyParticipant[]|error {
        GetDutyParticipantsResponse|graphql:ClientError getDutyParticipantsResponse = globalDataClient->getDutyParticipants(organization_id);
        if(getDutyParticipantsResponse is GetDutyParticipantsResponse) {
            DutyParticipant[] dutyParticipants = [];
            foreach var duty_participant in getDutyParticipantsResponse.duty_participants {
                DutyParticipant|error dutyParticipant = duty_participant.cloneWithType(DutyParticipant);
                if(dutyParticipant is DutyParticipant) {
                    dutyParticipants.push(dutyParticipant);
                } else {
                    log:printError("Error while processing Application record received",dutyParticipant);
                    return error("Error while processing Application record received: " + dutyParticipant.message() + 
                        ":: Detail: " + dutyParticipant.detail().toString());
                }
            }

            return dutyParticipants;
            
        } else {
            log:printError("Error while getting application", getDutyParticipantsResponse );
            return error("Error while getting application: " + getDutyParticipantsResponse .message() + 
                ":: Detail: " + getDutyParticipantsResponse.detail().toString());
        }
    }

    resource function post duty_for_participant (@http:Payload DutyParticipant dutyParticipant) returns DutyParticipant|error {
        CreateDutyForParticipantResponse|graphql:ClientError createDutyForParticipantResponse = globalDataClient->createDutyForParticipant(dutyParticipant);
        if(createDutyForParticipantResponse is CreateDutyForParticipantResponse) {
            DutyParticipant|error duty_for_participant_record = createDutyForParticipantResponse.add_duty_for_participant.cloneWithType(DutyParticipant);
            if(duty_for_participant_record is DutyParticipant) {
                return duty_for_participant_record;
            } else {
                log:printError("Error while processing Application record received", duty_for_participant_record);
                return error("Error while processing Application record received: " + duty_for_participant_record.message() + 
                    ":: Detail: " + duty_for_participant_record.detail().toString());
            }
        } else {
            log:printError("Error while creating application", createDutyForParticipantResponse);
            return error("Error while creating application: " + createDutyForParticipantResponse.message() + 
                ":: Detail: " + createDutyForParticipantResponse.detail().toString());
        }
    }

    resource function get activities_by_avinya_type/[int avinya_type_id]() returns Activity[]|error {
        GetActivitiesByAvinyaTypeResponse|graphql:ClientError getActivitiesByAvinyaTypeResponse = globalDataClient->getActivitiesByAvinyaType(avinya_type_id);
        if(getActivitiesByAvinyaTypeResponse is GetActivitiesByAvinyaTypeResponse) {
            Activity[] activitiesByAvinyaType = [];
            foreach var activity_by_avinya_type  in getActivitiesByAvinyaTypeResponse.activities_by_avinya_type {
                Activity|error activityByAvinyaType = activity_by_avinya_type.cloneWithType(Activity);
                if(activityByAvinyaType is Activity) {
                    activitiesByAvinyaType.push(activityByAvinyaType);
                } else {
                    log:printError("Error while processing Application record received",activityByAvinyaType);
                    return error("Error while processing Application record received: " + activityByAvinyaType.message() + 
                        ":: Detail: " + activityByAvinyaType.detail().toString());
                }
            }

            return activitiesByAvinyaType;
            
        } else {
            log:printError("Error while getting application", getActivitiesByAvinyaTypeResponse );
            return error("Error while getting application: " + getActivitiesByAvinyaTypeResponse .message() + 
                ":: Detail: " + getActivitiesByAvinyaTypeResponse.detail().toString());
        }
    }

    resource function delete duty_for_participant/[int id]() returns json|error {
        json|error delete_count = globalDataClient->deleteDutyForParticipant(id);
        return  delete_count;
    }


    resource function put update_duty_rotation_metadata(@http:Payload DutyRotationMetaDetails dutyRotationMetadata) returns DutyRotationMetaDetails|error {
        UpdateDutyRotationMetaDataResponse|graphql:ClientError updateDutyRotationMetaDataResponse = globalDataClient->updateDutyRotationMetaData(dutyRotationMetadata);
        if(updateDutyRotationMetaDataResponse is  UpdateDutyRotationMetaDataResponse) {
            DutyRotationMetaDetails|error duty_rotation__meta_data_record = updateDutyRotationMetaDataResponse.update_duty_rotation_metadata.cloneWithType(DutyRotationMetaDetails);
            if(duty_rotation__meta_data_record is  DutyRotationMetaDetails) {
                return duty_rotation__meta_data_record;
            } else {
                log:printError("Error while processing Application record received", duty_rotation__meta_data_record);
                return error("Error while processing Application record received: " + duty_rotation__meta_data_record.message() + 
                    ":: Detail: " + duty_rotation__meta_data_record.detail().toString());
            }
        } else {
            log:printError("Error while updating application", updateDutyRotationMetaDataResponse);
            return error("Error while updating application: " + updateDutyRotationMetaDataResponse.message() + 
                ":: Detail: " + updateDutyRotationMetaDataResponse.detail().toString());
        }
    }

    resource function get duty_rotation_metadata_by_organization/[int organization_id]() returns DutyRotationMetaDetails|error {
        GetDutyRotationMetadataByOrganizationResponse|graphql:ClientError getDutyRotationMetadataByOrganizationResponse = globalDataClient->getDutyRotationMetadataByOrganization(organization_id);
        if(getDutyRotationMetadataByOrganizationResponse is GetDutyRotationMetadataByOrganizationResponse) {
            DutyRotationMetaDetails|error duty_rotation_metadata_by_organization_record = getDutyRotationMetadataByOrganizationResponse.duty_rotation_metadata_by_organization.cloneWithType(DutyRotationMetaDetails);
            if(duty_rotation_metadata_by_organization_record is DutyRotationMetaDetails) {
                return duty_rotation_metadata_by_organization_record;
            } else {
                log:printError("Error while processing Application record received", duty_rotation_metadata_by_organization_record);
                return error("Error while processing Application record received: " + duty_rotation_metadata_by_organization_record.message() + 
                    ":: Detail: " + duty_rotation_metadata_by_organization_record.detail().toString());
            }

        }else if(getDutyRotationMetadataByOrganizationResponse is graphql:ClientError){

            DutyRotationMetaDetails duty ={ end_date: (),start_date: (),organization_id:(),id:()};
                
            return duty;
       } 
    }

    
    resource function get duty_participants_by_duty_activity_id/[int organization_id]/[int duty_activity_id]() returns DutyParticipant[]|error {
        GetDutyParticipantsByDutyActivityIdResponse|graphql:ClientError getDutyParticipantsByDutyActivityIdResponse = globalDataClient->getDutyParticipantsByDutyActivityId(organization_id, duty_activity_id);
        if(getDutyParticipantsByDutyActivityIdResponse is GetDutyParticipantsByDutyActivityIdResponse) {
            DutyParticipant[] dutyParticipants = [];
            foreach var duty_participant_by_duty_activity_id in getDutyParticipantsByDutyActivityIdResponse.duty_participants_by_duty_activity_id {
                DutyParticipant|error dutyParticipantByDutyActivityId = duty_participant_by_duty_activity_id.cloneWithType(DutyParticipant);
                if(dutyParticipantByDutyActivityId is DutyParticipant) {
                    dutyParticipants.push(dutyParticipantByDutyActivityId);
                } else {
                    log:printError("Error while processing Application record received",dutyParticipantByDutyActivityId);
                    return error("Error while processing Application record received: " + dutyParticipantByDutyActivityId.message() + 
                        ":: Detail: " + dutyParticipantByDutyActivityId.detail().toString());
                }
            }

            return dutyParticipants;
            
        } else {
            log:printError("Error while getting application", getDutyParticipantsByDutyActivityIdResponse );
            return error("Error while getting application: " + getDutyParticipantsByDutyActivityIdResponse .message() + 
                ":: Detail: " + getDutyParticipantsByDutyActivityIdResponse.detail().toString());
        }
    }

    resource function post duty_attendance (@http:Payload ActivityParticipantAttendance dutyAttendance) returns ActivityParticipantAttendance|error {
        AddDutyAttendanceResponse|graphql:ClientError addDutyAttendanceResponse = globalDataClient->addDutyAttendance(dutyAttendance);
        if(addDutyAttendanceResponse is AddDutyAttendanceResponse) {
            ActivityParticipantAttendance|error duty_attendance_record = addDutyAttendanceResponse.add_duty_attendance.cloneWithType(ActivityParticipantAttendance);
            if(duty_attendance_record is ActivityParticipantAttendance) {
                return duty_attendance_record;
            } else {
                log:printError("Error while processing Application record received", duty_attendance_record);
                return error("Error while processing Application record received: " + duty_attendance_record.message() + 
                    ":: Detail: " + duty_attendance_record.detail().toString());
            }
        } else {
            log:printError("Error while creating application", addDutyAttendanceResponse);
            return error("Error while creating application: " + addDutyAttendanceResponse.message() + 
                ":: Detail: " + addDutyAttendanceResponse.detail().toString());
        }
    }

    resource function get duty_attendance_today/[int organization_id]/[int activity_id]() returns ActivityParticipantAttendance[]|error {
        GetDutyAttendanceTodayResponse|graphql:ClientError getDutyAttendanceTodayResponse = globalDataClient->getDutyAttendanceToday(organization_id, activity_id);
        if(getDutyAttendanceTodayResponse is GetDutyAttendanceTodayResponse) {
            ActivityParticipantAttendance[] dutyParticipantAttendances = [];
            foreach var duty_attendance_record in getDutyAttendanceTodayResponse.duty_attendance_today {
                ActivityParticipantAttendance|error dutyParticipantAttendance = duty_attendance_record.cloneWithType(ActivityParticipantAttendance);
                if(dutyParticipantAttendance is ActivityParticipantAttendance) {
                    dutyParticipantAttendances.push(dutyParticipantAttendance);
                } else {
                    log:printError("Error while processing Application record received", dutyParticipantAttendance);
                    return error("Error while processing Application record received: " + dutyParticipantAttendance.message() + 
                        ":: Detail: " + dutyParticipantAttendance.detail().toString());
                }
            }

            return dutyParticipantAttendances;
            
        } else {
            log:printError("Error while creating application", getDutyAttendanceTodayResponse);
            return error("Error while creating application: " + getDutyAttendanceTodayResponse.message() + 
                ":: Detail: " + getDutyAttendanceTodayResponse.detail().toString());
        }
    }

    resource function get duty_participant/[int person_id]() returns DutyParticipant|error {
        GetDutyParticipantResponse|graphql:ClientError getDutyParticipantResponse = globalDataClient->getDutyParticipant(person_id);
        if(getDutyParticipantResponse is GetDutyParticipantResponse) {
            DutyParticipant|error duty_participant_record = getDutyParticipantResponse.duty_participant.cloneWithType(DutyParticipant);
            if(duty_participant_record is DutyParticipant) {
                return duty_participant_record;
            } else {
                log:printError("Error while processing Application record received",duty_participant_record);
                return error("Error while processing Application record received: " + duty_participant_record.message() + 
                    ":: Detail: " + duty_participant_record.detail().toString());
            }
        }else if(getDutyParticipantResponse is graphql:ClientError){

            DutyParticipant dutyParticipant ={ role: (),activity: (),person:(),id:()};
                
            return dutyParticipant;
       }        
    }
           resource function get attendance_dashboard_card_data/[string from_date]/[string to_date]/[int organization_id]() returns AttendanceDashboardDataMain[]|error {
            log:printInfo("Time parent_organization_id");
            log:printInfo(organization_id.toString());
        GetAttendanceDashboardResponse|graphql:ClientError getAttendanceDashboardResponse = globalDataClient->getAttendanceDashboard(from_date, to_date,organization_id);
        log:printInfo((check getAttendanceDashboardResponse).toString());
        if(getAttendanceDashboardResponse is GetAttendanceDashboardResponse) {
            AttendanceDashboardDataMain[] attendanceDashboardDatas = [];
            foreach var attendance_dashboard_record in getAttendanceDashboardResponse.attendance_dashboard_data_by_date {
                log:printInfo("Time dddddddddddd");
                log:printInfo((attendance_dashboard_record).toString());
                AttendanceDashboardDataMain|error attendanceDashboardData = attendance_dashboard_record.cloneWithType(AttendanceDashboardDataMain);
                if(attendanceDashboardData is AttendanceDashboardDataMain) {
                    attendanceDashboardDatas.push(attendanceDashboardData);
                } else {
                    log:printError("Error while processing Application record received", attendanceDashboardData);
                    return error("Error while processing Application record received: " + attendanceDashboardData.message() + 
                        ":: Detail: " + attendanceDashboardData.detail().toString());
                }
            }

            return attendanceDashboardDatas;
            
        }else if(getAttendanceDashboardResponse is graphql:ClientError){
            AttendanceDashboardDataMain[] attendanceDashboardDatas = [];
            return attendanceDashboardDatas;
        }
    }
        resource function get attendance_dashboard_card_data_by_parent_org/[string from_date]/[string to_date]/[int parent_organization_id]() returns AttendanceDashboardDataMain[]|error {
            log:printInfo("Time parent_organization_id");
            log:printInfo(parent_organization_id.toString());
        GetAttendanceDashboardResponse|graphql:ClientError getAttendanceDashboardResponse = globalDataClient->getAttendanceDashboardbyParentOrgId(from_date, to_date,parent_organization_id);
        if(getAttendanceDashboardResponse is GetAttendanceDashboardResponse) {
            AttendanceDashboardDataMain[] attendanceDashboardDatas = [];
            foreach var attendance_dashboard_record in getAttendanceDashboardResponse.attendance_dashboard_data_by_date {
                AttendanceDashboardDataMain|error attendanceDashboardData = attendance_dashboard_record.cloneWithType(AttendanceDashboardDataMain);
                if(attendanceDashboardData is AttendanceDashboardDataMain) {
                    attendanceDashboardDatas.push(attendanceDashboardData);
                } else {
                    log:printError("Error while processing Application record received", attendanceDashboardData);
                    return error("Error while processing Application record received: " + attendanceDashboardData.message() + 
                        ":: Detail: " + attendanceDashboardData.detail().toString());
                }
            }

            return attendanceDashboardDatas;
            
        } else {
            log:printError("Error while creating application", getAttendanceDashboardResponse);
            return error("Error while creating application: " + getAttendanceDashboardResponse.message() + 
                ":: Detail: " + getAttendanceDashboardResponse.detail().toString());
        }
    }

    resource function post duty_evaluation (@http:Payload Evaluation dutyEvaluation) returns Evaluation|error {
        CreateDutyEvaluationResponse|graphql:ClientError  addDutyEvaluationResponse = globalDataClient->createDutyEvaluation(dutyEvaluation);
        if(addDutyEvaluationResponse is CreateDutyEvaluationResponse) {
            Evaluation|error duty_evaluation_record = addDutyEvaluationResponse.add_duty_evaluation.cloneWithType(Evaluation);
            if(duty_evaluation_record is Evaluation) {
                return duty_evaluation_record;
            } else {
                log:printError("Error while processing Application record received", duty_evaluation_record);
                return error("Error while processing Application record received: " + duty_evaluation_record.message() + 
                    ":: Detail: " + duty_evaluation_record.detail().toString());
            }
        } else {
            log:printError("Error while creating application", addDutyEvaluationResponse);
            return error("Error while creating application: " + addDutyEvaluationResponse.message() + 
                ":: Detail: " + addDutyEvaluationResponse.detail().toString());
        }
    }

    resource function get attendance_missed_by_security_by_org/[int organization_id]/[string from_date]/[string to_date]() returns ActivityParticipantAttendance[]|error {
        GetAttendanceMissedBySecurityByOrgResponse|graphql:ClientError getAttendanceMissedBySecurityResponse = globalDataClient->getAttendanceMissedBySecurityByOrg(from_date, to_date, organization_id);
        if(getAttendanceMissedBySecurityResponse is GetAttendanceMissedBySecurityByOrgResponse) {
            ActivityParticipantAttendance[] activityParticipantAttendances = [];
            foreach var attendance_record in getAttendanceMissedBySecurityResponse.attendance_missed_by_security {
                ActivityParticipantAttendance|error activityParticipantAttendance = attendance_record.cloneWithType(ActivityParticipantAttendance);
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
            log:printError("Error while creating application", getAttendanceMissedBySecurityResponse);
            return error("Error while creating application: " + getAttendanceMissedBySecurityResponse.message() + 
                ":: Detail: " + getAttendanceMissedBySecurityResponse.detail().toString());
        }
    }

    resource function get attendance_missed_by_security_by_parent_org/[int parent_organization_id]/[string from_date]/[string to_date]() returns ActivityParticipantAttendance[]|error {
        GetAttendanceMissedBySecurityByParentOrgResponse|graphql:ClientError getAttendanceMissedBySecurityResponse = globalDataClient->getAttendanceMissedBySecurityByParentOrg(from_date,to_date,parent_organization_id);
        if(getAttendanceMissedBySecurityResponse is GetAttendanceMissedBySecurityByParentOrgResponse) {
            ActivityParticipantAttendance[] activityParticipantAttendances = [];
            foreach var attendance_record in getAttendanceMissedBySecurityResponse.attendance_missed_by_security {
                ActivityParticipantAttendance|error activityParticipantAttendance = attendance_record.cloneWithType(ActivityParticipantAttendance);
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
            log:printError("Error while creating application", getAttendanceMissedBySecurityResponse);
            return error("Error while creating application: " + getAttendanceMissedBySecurityResponse.message() + 
                ":: Detail: " + getAttendanceMissedBySecurityResponse.detail().toString());
        }
    }

    resource function get daily_students_attendance_by_parent_org/[int parent_organization_id]() returns DailyActivityParticipantAttendanceByParentOrg[]|error {
        GetDailyStudentsAttendanceByParentOrgResponse|graphql:ClientError getDailyStudentsAttendanceResponse = globalDataClient->getDailyStudentsAttendanceByParentOrg(parent_organization_id);
        if(getDailyStudentsAttendanceResponse is GetDailyStudentsAttendanceByParentOrgResponse) {
            DailyActivityParticipantAttendanceByParentOrg[] dailyStudentsAttendances = [];
            foreach var daily_students_attendance_record in getDailyStudentsAttendanceResponse.daily_students_attendance_by_parent_org {
                DailyActivityParticipantAttendanceByParentOrg|error dailyStudentsAttendance = daily_students_attendance_record.cloneWithType(DailyActivityParticipantAttendanceByParentOrg);
                if(dailyStudentsAttendance is DailyActivityParticipantAttendanceByParentOrg) {
                    dailyStudentsAttendances.push(dailyStudentsAttendance);
                } else {
                    log:printError("Error while processing Application record received", dailyStudentsAttendance);
                    return error("Error while processing Application record received: " + dailyStudentsAttendance.message() + 
                        ":: Detail: " + dailyStudentsAttendance.detail().toString());
                }
            }

            return dailyStudentsAttendances;
            
        } else {
            log:printError("Error while creating application", getDailyStudentsAttendanceResponse);
            return error("Error while creating application: " + getDailyStudentsAttendanceResponse.message() + 
                ":: Detail: " + getDailyStudentsAttendanceResponse.detail().toString());
        }
    }

    resource function get total_attendance_count_by_date_by_org/[int organization_id]/[string from_date]/[string to_date]() returns TotalAttendanceCountByDate[]|error {
        GetTotalAttendanceCountByDateByOrgResponse|graphql:ClientError getTotalAttendanceCountResponse = globalDataClient->getTotalAttendanceCountByDateByOrg(from_date, to_date, organization_id);
        if(getTotalAttendanceCountResponse is GetTotalAttendanceCountByDateByOrgResponse) {
            TotalAttendanceCountByDate[] totalAttendances = [];
            foreach var total_attendance_record in getTotalAttendanceCountResponse.total_attendance_count_by_date {
                TotalAttendanceCountByDate|error totalAttendanceRecord = total_attendance_record.cloneWithType(TotalAttendanceCountByDate);
                if(totalAttendanceRecord is TotalAttendanceCountByDate) {
                    totalAttendances.push(totalAttendanceRecord);
                } else {
                    log:printError("Error while processing Application record received", totalAttendanceRecord);
                    return error("Error while processing Application record received: " + totalAttendanceRecord.message() + 
                        ":: Detail: " + totalAttendanceRecord.detail().toString());
                }
            }

            return totalAttendances;
            
        } else {
            log:printError("Error while creating application", getTotalAttendanceCountResponse);
            return error("Error while creating application: " + getTotalAttendanceCountResponse.message() + 
                ":: Detail: " + getTotalAttendanceCountResponse.detail().toString());
        }
    }

    resource function get total_attendance_count_by_date_by_parent_org/[int parent_organization_id]/[string from_date]/[string to_date]() returns TotalAttendanceCountByDate[]|error {
        GetTotalAttendanceCountByParentOrgResponse|graphql:ClientError getTotalAttendanceCountResponse = globalDataClient->getTotalAttendanceCountByParentOrg(from_date,to_date,parent_organization_id);
        if(getTotalAttendanceCountResponse is GetTotalAttendanceCountByParentOrgResponse) {
            TotalAttendanceCountByDate[] totalAttendances = [];
            foreach var total_attendance_record in getTotalAttendanceCountResponse.total_attendance_count_by_date {
                TotalAttendanceCountByDate|error totalAttendanceRecord = total_attendance_record.cloneWithType(TotalAttendanceCountByDate);
                if(totalAttendanceRecord is TotalAttendanceCountByDate) {
                    totalAttendances.push(totalAttendanceRecord);
                } else {
                    log:printError("Error while processing Application record received", totalAttendanceRecord);
                    return error("Error while processing Application record received: " + totalAttendanceRecord.message() + 
                        ":: Detail: " + totalAttendanceRecord.detail().toString());
                }
            }

            return totalAttendances;
            
        } else {
            log:printError("Error while creating application", getTotalAttendanceCountResponse);
            return error("Error while creating application: " + getTotalAttendanceCountResponse.message() + 
                ":: Detail: " + getTotalAttendanceCountResponse.detail().toString());
        }
    }

    resource function get daily_attendance_summary_report/[int organization_id]/[int avinya_type_id]/[string from_date]/[string to_date]() returns ActivityParticipantAttendanceSummary[]|error {
        GetDailyAttendanceSummaryReportResponse|graphql:ClientError getDailyAttendanceSummaryReportResponse = globalDataClient->getDailyAttendanceSummaryReport(from_date,to_date,organization_id,avinya_type_id);
        if(getDailyAttendanceSummaryReportResponse is GetDailyAttendanceSummaryReportResponse) {
            ActivityParticipantAttendanceSummary[] activityParticipantAttendances = [];
            foreach var attendance_record in getDailyAttendanceSummaryReportResponse.daily_attendance_summary_report {
                ActivityParticipantAttendanceSummary|error activityParticipantAttendance = attendance_record.cloneWithType(ActivityParticipantAttendanceSummary);
                if(activityParticipantAttendance is ActivityParticipantAttendanceSummary) {
                    activityParticipantAttendances.push(activityParticipantAttendance);
                } else {
                    log:printError("Error while processing Application record received", activityParticipantAttendance);
                    return error("Error while processing Application record received: " + activityParticipantAttendance.message() + 
                        ":: Detail: " + activityParticipantAttendance.detail().toString());
                }
            }

            return activityParticipantAttendances;
            
        } else {
            log:printError("Error while creating application", getDailyAttendanceSummaryReportResponse);
            return error("Error while creating application: " + getDailyAttendanceSummaryReportResponse.message() + 
                ":: Detail: " + getDailyAttendanceSummaryReportResponse.detail().toString());
        }
    }

    resource function get organizations_by_avinya_type_and_status(int? avinya_type,int? active) returns Organization[]|error {
        GetOrganizationsByAvinyaTypeAndStatusResponse|graphql:ClientError getOrganizationsByAvinyaTypeAndStatusResponse = globalDataClient->getOrganizationsByAvinyaTypeAndStatus(avinya_type,active);
        if(getOrganizationsByAvinyaTypeAndStatusResponse is GetOrganizationsByAvinyaTypeAndStatusResponse) {
            Organization[] organizations = [];
            foreach var organization_record in getOrganizationsByAvinyaTypeAndStatusResponse.organizations_by_avinya_type_and_status {
                Organization|error organization = organization_record.cloneWithType(Organization);
                if(organization is Organization) {
                    organizations.push(organization);
                } else {
                    log:printError("Error while processing Application record received", organization);
                    return error("Error while processing Application record received: " + organization.message() + 
                        ":: Detail: " + organization.detail().toString());
                }
            }

            return organizations;
            
        } else {
            log:printError("Error while creating application", getOrganizationsByAvinyaTypeAndStatusResponse);
            return error("Error while creating application: " + getOrganizationsByAvinyaTypeAndStatusResponse.message() + 
                ":: Detail: " + getOrganizationsByAvinyaTypeAndStatusResponse.detail().toString());
        }
    }

    resource function post add_monthly_leave_dates (@http:Payload MonthlyLeaveDates monthlyLeaveDates) returns MonthlyLeaveDates|error {
        CreateMonthlyLeaveDatesResponse|graphql:ClientError addMonthlyLeaveDatesResponse = globalDataClient->createMonthlyLeaveDates(monthlyLeaveDates);
        if(addMonthlyLeaveDatesResponse is CreateMonthlyLeaveDatesResponse) {
            MonthlyLeaveDates|error monthly_leave_dates_record = addMonthlyLeaveDatesResponse.add_monthly_leave_dates.cloneWithType(MonthlyLeaveDates);
            if(monthly_leave_dates_record is MonthlyLeaveDates) {
                return monthly_leave_dates_record;
            } else {
                log:printError("Error while processing Application record received", monthly_leave_dates_record);
                return error("Error while processing Application record received: " + monthly_leave_dates_record.message() + 
                    ":: Detail: " + monthly_leave_dates_record.detail().toString());
            }
        } else {
            log:printError("Error while creating application", addMonthlyLeaveDatesResponse);
            return error("Error while creating application: " + addMonthlyLeaveDatesResponse.message() + 
                ":: Detail: " + addMonthlyLeaveDatesResponse.detail().toString());
        }
    }

    resource function put update_monthly_leave_dates(@http:Payload MonthlyLeaveDates monthlyLeaveDates) returns MonthlyLeaveDates|error {
        UpdateMonthlyLeaveDatesResponse|graphql:ClientError updateMonthlyLeaveDatesResponse = globalDataClient->updateMonthlyLeaveDates(monthlyLeaveDates);
        if(updateMonthlyLeaveDatesResponse is  UpdateMonthlyLeaveDatesResponse) {
            MonthlyLeaveDates|error monthly_leave_dates_record = updateMonthlyLeaveDatesResponse.update_monthly_leave_dates.cloneWithType(MonthlyLeaveDates);
            if(monthly_leave_dates_record is  MonthlyLeaveDates) {
                return monthly_leave_dates_record;
            } else {
                log:printError("Error while processing Application record received", monthly_leave_dates_record);
                return error("Error while processing Application record received: " + monthly_leave_dates_record.message() + 
                    ":: Detail: " + monthly_leave_dates_record.detail().toString());
            }
        } else {
            log:printError("Error while updating application", updateMonthlyLeaveDatesResponse);
            return error("Error while updating application: " + updateMonthlyLeaveDatesResponse.message() + 
                ":: Detail: " + updateMonthlyLeaveDatesResponse.detail().toString());
        }
    }
    
    resource function get monthly_leave_dates_record_by_id/[int organization_id]/[int batch_id]/[int year]/[int month]() returns MonthlyLeaveDates|error {
        GetMonthlyLeaveDatesRecordByIdResponse|graphql:ClientError getMonthlyLeaveDatesRecordByIdResponse = globalDataClient->getMonthlyLeaveDatesRecordById(month,batch_id,year,organization_id);
        if (getMonthlyLeaveDatesRecordByIdResponse is GetMonthlyLeaveDatesRecordByIdResponse) {
            MonthlyLeaveDates|error monthly_leave_dates_record_by_id_record = getMonthlyLeaveDatesRecordByIdResponse.monthly_leave_dates_record_by_id.cloneWithType(MonthlyLeaveDates);
            if (monthly_leave_dates_record_by_id_record is MonthlyLeaveDates) {
                return monthly_leave_dates_record_by_id_record;
            } else {
                log:printError("Error while processing Application record received", monthly_leave_dates_record_by_id_record);
                return error("Error while processing Application record received: " + monthly_leave_dates_record_by_id_record.message() +
                    ":: Detail: " + monthly_leave_dates_record_by_id_record.detail().toString());
            }
        } else {
            log:printError("Error while creating application", getMonthlyLeaveDatesRecordByIdResponse);
            return error("Error while creating application: " + getMonthlyLeaveDatesRecordByIdResponse.message() +
                ":: Detail: " + getMonthlyLeaveDatesRecordByIdResponse.detail().toString());
        }
    }
    resource function get batch_payment_plan_by_org_id/[int organization_id]/[int batch_id]/[string selected_month_date]() returns BatchPaymentPlan|error {
        GetBatchPaymentPlanByOrgIdResponse|graphql:ClientError getBatchPaymentPlanByOrgIdResponse = globalDataClient->getBatchPaymentPlanByOrgId(selected_month_date,batch_id,organization_id);
        if (getBatchPaymentPlanByOrgIdResponse is GetBatchPaymentPlanByOrgIdResponse) {
            BatchPaymentPlan|error batch_payment_plan_record = getBatchPaymentPlanByOrgIdResponse.batch_payment_plan_by_org_id.cloneWithType(BatchPaymentPlan);
            if (batch_payment_plan_record is BatchPaymentPlan) {
                return batch_payment_plan_record;
            } else {
                log:printError("Error while processing Application record received", batch_payment_plan_record);
                return error("Error while processing Application record received: " + batch_payment_plan_record.message() +
                    ":: Detail: " + batch_payment_plan_record.detail().toString());
            }
        } else {
            log:printError("Error while creating application", getBatchPaymentPlanByOrgIdResponse);
            return error("Error while creating application: " + getBatchPaymentPlanByOrgIdResponse.message() +
                ":: Detail: " + getBatchPaymentPlanByOrgIdResponse.detail().toString());
        }
    }

}
