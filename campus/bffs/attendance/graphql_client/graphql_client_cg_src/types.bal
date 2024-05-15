public type Activity record {
    string? notes?;
    int[]? parent_activities?;
    string? created?;
    string? name?;
    int? avinya_type_id?;
    int[]? child_activities?;
    string? description?;
    int? id?;
    string? updated?;
    string? record_type?;
};

public type ActivityInstance record {
    string? notes?;
    string? created?;
    int? weekly_sequence?;
    string? end_time?;
    string? description?;
    int? daily_sequence?;
    string? record_type?;
    int? monthly_sequence?;
    string? start_time?;
    int? organization_id?;
    int? activity_id?;
    string? name?;
    int? id?;
    string? updated?;
    int? place_id?;
};

public type ActivityParticipant record {
    string? end_date?;
    int? activity_instance_id?;
    string? role?;
    string? notes?;
    string? created?;
    int? organization_id?;
    int? id?;
    string? updated?;
    string? record_type?;
    int? person_id?;
    string? start_date?;
};

public type ActivityParticipantAttendance record {
    int? activity_instance_id?;
    string? in_marked_by?;
    string? created?;
    string? sign_in_time?;
    int? id?;
    string? out_marked_by?;
    string? updated?;
    string? record_type?;
    int? person_id?;
    string? sign_out_time?;
};

public type ActivitySequencePlan record {
    int? sequence_number?;
    int? timeslot_number?;
    string? created?;
    int? organization_id?;
    int? activity_id?;
    int? id?;
    string? updated?;
    string? record_type?;
    int? person_id?;
};

public type Address record {
    string street_address?;
    string? name_ta?;
    int? phone?;
    string? name_si?;
    int? id?;
    string? record_type?;
    int city_id?;
    string name_en?;
};

public type ApplicantConsent record {
    string? date_of_birth?;
    string? al_stream?;
    string? created?;
    int? avinya_type_id?;
    boolean? agree_terms_consent?;
    boolean? active?;
    int? al_year?;
    string? done_ol?;
    int? application_id?;
    int? ol_year?;
    string? record_type?;
    boolean? information_correct_consent?;
    int? phone?;
    int? organization_id?;
    string? name?;
    int? id?;
    int? distance_to_school?;
    string? updated?;
    string? done_al?;
    string? email?;
    int? person_id?;
};

public type Application record {
    int? vacancy_id?;
    string? application_date?;
    int? id?;
    string? record_type?;
    int? person_id?;
};

public type Asset record {
    string? registration_number?;
    string? created?;
    string? name?;
    int? avinya_type_id?;
    string? description?;
    string? model?;
    string? serial_number?;
    int? id?;
    string? updated?;
    string? record_type?;
    string? manufacturer?;
};

public type AvinyaType record {
    int? level?;
    string? name?;
    boolean active?;
    string? description?;
    string? foundation_type?;
    string? focus?;
    int? id?;
    string? record_type?;
    string global_type?;
};

public type Consumable record {
    string? created?;
    int? avinya_type_id?;
    string? name?;
    string? description?;
    string? model?;
    string? serial_number?;
    int? id?;
    string? updated?;
    string? record_type?;
    string? manufacturer?;
};

public type DutyParticipant record {
    string? role?;
    Activity? activity?;
    Person? person?;
    string? created?;
    int? activity_id?;
    int? id?;
    string? updated?;
    string? record_type?;
    int? person_id?;
};

public type DutyRotationMetaDetails record {
    string? end_date?;
    int? organization_id?;
    int? id?;
    string? record_type?;
    string? start_date?;
};

public type EducationExperience record {
    string? end_date?;
    int[]? evaluation_id?;
    string? school?;
    int? id?;
    string? record_type?;
    int? person_id?;
    string? start_date?;
};

public type Evaluation record {
    int[]? parent_evaluations?;
    string? notes?;
    int? evaluatee_id?;
    string? created?;
    int[]? child_evaluations?;
    string? record_type?;
    int? activity_instance_id?;
    int? evaluation_criteria_id?;
    string? response?;
    int? evaluator_id?;
    int? grade?;
    int? id?;
    string? updated?;
};

public type EvaluationCriteria record {
    string? difficulty?;
    int? rating_out_of?;
    string? description?;
    string? evaluation_type?;
    int? id?;
    string? prompt?;
    string? expected_answer?;
    string? record_type?;
};

public type EvaluationCriteriaAnswerOption record {
    string? answer?;
    int? evaluation_criteria_id?;
    int? id?;
    boolean? expected_answer?;
    string? record_type?;
};

public type EvaluationCycle record {
    string? end_date?;
    string? name?;
    string? description?;
    int? id?;
    string? record_type?;
    string? start_date?;
};

public type EvaluationMetadata record {
    string? meta_type?;
    int? evaluation_id?;
    string? metadata?;
    int? level?;
    string? on_date_time?;
    string? focus?;
    string? location?;
    int? id?;
    string? record_type?;
    string? status?;
};

public type Inventory record {
    int? quantity_out?;
    int? consumable_id?;
    int? quantity?;
    int? quantity_in?;
    string? created?;
    int? organization_id?;
    int? avinya_type_id?;
    int? id?;
    int? asset_id?;
    string? updated?;
    string? record_type?;
    int? person_id?;
};

public type Organization record {
    int[]? parent_organizations?;
    string? notes?;
    string? name_ta?;
    int[]? child_organizations?;
    int? phone?;
    int? address_id?;
    string? name_si?;
    int? avinya_type?;
    string? description?;
    int? id?;
    string? record_type?;
    string name_en?;
};

public type Person record {
    int? permanent_address_id?;
    string? street_address?;
    string? bank_branch?;
    string? bank_account_number?;
    string? notes?;
    int[]? parent_student?;
    string? date_of_birth?;
    int? avinya_type_id?;
    Address? permanent_address?;
    int? mailing_address_id?;
    string? id_no?;
    string? jwt_email?;
    string? bank_name?;
    int? id?;
    string? email?;
    string? created?;
    string? digital_id?;
    string? sex?;
    string? passport_no?;
    string? record_type?;
    Address? mailing_address?;
    string? branch_code?;
    int[]? child_student?;
    string? bank_account_name?;
    int? avinya_phone?;
    string? full_name?;
    string? nic_no?;
    int? phone?;
    int? organization_id?;
    string? academy_org_name?;
    string? asgardeo_id?;
    string? updated?;
    string? preferred_name?;
    string? jwt_sub_id?;
    int? academy_org_id?;
};

public type Prospect record {
    string? street_address?;
    boolean? contacted?;
    boolean? applied?;
    string? created?;
    string? date_of_birth?;
    boolean? agree_terms_consent?;
    boolean? verified?;
    boolean? active?;
    boolean? receive_information_consent?;
    boolean? done_ol?;
    int? ol_year?;
    string? record_type?;
    int? phone?;
    string? name?;
    int? id?;
    int? distance_to_school?;
    string? updated?;
    string? email?;
};

public type ResourceAllocation record {
    string? end_date?;
    int? consumable_id?;
    int? quantity?;
    string? created?;
    int? asset_id?;
    string? record_type?;
    ResourceProperty[]? resource_properties?;
    boolean? requested?;
    boolean? approved?;
    int? organization_id?;
    int? id?;
    string? updated?;
    boolean? allocated?;
    int? person_id?;
    string? start_date?;
};

public type ResourceProperty record {
    int? consumable_id?;
    string? property?;
    int? id?;
    int? asset_id?;
    string? value?;
    string? record_type?;
};

public type Supplier record {
    int? phone?;
    string? created?;
    string? name?;
    int? address_id?;
    string? description?;
    int? id?;
    string? updated?;
    string? record_type?;
    string? email?;
};

public type Supply record {
    string? order_date?;
    string? delivery_date?;
    int? consumable_id?;
    string? created?;
    int? order_amount?;
    int? id?;
    int? asset_id?;
    int? supplier_id?;
    string? order_id?;
    string? updated?;
    string? record_type?;
    int? person_id?;
};

public type Vacancy record {
    int? organization_id?;
    string? name?;
    int? avinya_type_id?;
    string? description?;
    int? evaluation_cycle_id?;
    int? head_count?;
    int? id?;
    string? record_type?;
};

public type WorkExperience record {
    string? end_date?;
    int[]? evaluation_id?;
    string? organization?;
    int? id?;
    string? record_type?;
    int? person_id?;
    string? start_date?;
};

public type GetAvinyaTypesResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        boolean active;
        string? name;
        string global_type;
        string? foundation_type;
        string? focus;
        int? level;
    |}[] avinya_types;
|};

public type CreateAvinyaTypeResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        boolean active;
        string? name;
        string global_type;
        string? foundation_type;
        string? focus;
        int? level;
    |}? add_avinya_type;
|};

public type UpdateAvinyaTypeResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        boolean active;
        string? name;
        string global_type;
        string? foundation_type;
        string? focus;
        int? level;
    |}? update_avinya_type;
|};

public type GetActivityResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        string? name;
        string? description;
        string? notes;
        record {|
            int? id;
            string? name;
            string? description;
            string? notes;
            string? start_time;
            string? end_time;
            int? daily_sequence;
            int? weekly_sequence;
            int? monthly_sequence;
        |}[]? activity_instances;
        record {|
            int? id;
            string? name;
            string? description;
            string? notes;
            record {|
                int? id;
                string? name;
                string? description;
                string? notes;
                string? start_time;
                string? end_time;
                int? daily_sequence;
                int? weekly_sequence;
                int? monthly_sequence;
            |}[]? activity_instances;
            record {|
                int? id;
                int? sequence_number;
                int? timeslot_number;
                record {|
                    int? id;
                    record {|
                        string name_en;
                    |} name;
                |}? organization;
                record {|
                    string? preferred_name;
                |}? person;
            |}[]? activity_sequence_plan;
        |}[]? child_activities;
    |}? activity;
|};

public type AddActivityAttendanceResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        int? activity_instance_id;
        string? sign_in_time;
        string? sign_out_time;
        string? created;
    |}? add_attendance;
|};

public type GetActivityInstancesTodayResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        int? activity_id;
        string? name;
        int? daily_sequence;
        int? weekly_sequence;
        int? monthly_sequence;
        string? description;
        string? notes;
        string? start_time;
        string? end_time;
        string? created;
        string? updated;
        record {|
            int? id;
        |}? place;
        record {|
            int? id;
        |}? organization;
    |}[]? activity_instances_today;
|};

public type GetClassAttendanceTodayResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        int? person_id;
        record {|
            int? id;
        |}? person;
        int? activity_instance_id;
        string? sign_in_time;
        string? sign_out_time;
        string? in_marked_by;
        string? out_marked_by;
    |}[]? class_attendance_today;
|};

public type GetClassAttendanceReportResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        record {|
            int? id;
        |}? person;
        int? activity_instance_id;
        string? sign_in_time;
        string? sign_out_time;
        string? in_marked_by;
        string? out_marked_by;
    |}[]? class_attendance_report;
|};

public type GetPersonAttendanceReportResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        record {|
            int? id;
        |}? person;
        int? activity_instance_id;
        string? sign_in_time;
        string? sign_out_time;
        string? in_marked_by;
        string? out_marked_by;
    |}[]? person_attendance_report;
|};

public type GetPersonAttendanceTodayResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        record {|
            int? id;
        |}? person;
        int? activity_instance_id;
        string? sign_in_time;
        string? sign_out_time;
        string? in_marked_by;
        string? out_marked_by;
    |}[]? person_attendance_today;
|};

public type GetActivityEvaluationsResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        int? evaluatee_id;
        int? evaluator_id;
        int? evaluation_criteria_id;
        string? response;
        string? notes;
        int? grade;
        int? activity_instance_id;
        string? updated;
    |}[]? activity_evaluations;
|};

public type GetActivityInstanceEvaluationsResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        int? evaluatee_id;
        int? evaluator_id;
        int? evaluation_criteria_id;
        string? response;
        string? notes;
        int? grade;
        int? activity_instance_id;
        string? updated;
    |}[]? activity_instance_evaluations;
|};

public type UpdateEvaluationsResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        int? evaluatee_id;
        int? evaluator_id;
        int? evaluation_criteria_id;
        string? response;
        string? notes;
        int? grade;
        int? activity_instance_id;
        string? updated;
    |}? update_evaluation;
|};

public type GetDutyParticipantsResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        record {|
            int? id;
            string? name;
            string? description;
        |}? activity;
        record {|
            int? id;
            string? preferred_name;
            string? digital_id;
            record {|
                record {|
                    string name_en;
                |} name;
                string? description;
            |}? organization;
        |}? person;
        string? role;
    |}[] duty_participants;
|};

public type CreateDutyForParticipantResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        int? activity_id;
        int? person_id;
        string? role;
        string? created;
    |}? add_duty_for_participant;
|};

public type GetActivitiesByAvinyaTypeResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        string? name;
        string? description;
        string? notes;
    |}[]? activities_by_avinya_type;
|};

public type UpdateDutyRotationMetaDataResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        string? start_date;
        string? end_date;
        int? organization_id;
    |}? update_duty_rotation_metadata;
|};

public type GetDutyRotationMetadataByOrganizationResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        string? start_date;
        string? end_date;
        int? organization_id;
    |}? duty_rotation_metadata_by_organization;
|};

public type GetDutyParticipantsByDutyActivityIdResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        record {|
            int? id;
            string? name;
            string? description;
        |}? activity;
        record {|
            int? id;
            string? preferred_name;
            string? digital_id;
            record {|
                record {|
                    string name_en;
                |} name;
                string? description;
            |}? organization;
        |}? person;
        string? role;
    |}[] duty_participants_by_duty_activity_id;
|};

public type AddDutyAttendanceResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        int? activity_instance_id;
        int? person_id;
        string? sign_in_time;
        string? sign_out_time;
        string? in_marked_by;
        string? out_marked_by;
        string? created;
    |}? add_duty_attendance;
|};

public type GetDutyAttendanceTodayResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        int? person_id;
        int? activity_instance_id;
        string? sign_in_time;
        string? sign_out_time;
        string? in_marked_by;
        string? out_marked_by;
        string? created;
    |}[]? duty_attendance_today;
|};

public type GetDutyParticipantResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        record {|
            int? id;
            string? name;
            string? description;
        |}? activity;
        record {|
            int? id;
            string? preferred_name;
            string? digital_id;
            record {|
                record {|
                    string name_en;
                |} name;
                string? description;
            |}? organization;
        |}? person;
        string? role;
    |}? duty_participant;
|};

public type GetAttendanceDashboardResponse record {|
    map<json?> __extensions?;
    record {|record {|
            string? title;
            int? numOfFiles;
            string? svgSrc;
            string? color;
            anydata? percentage;
        |}? attendance_dashboard_data;|}[]? attendance_dashboard_data_by_date;
|};

public type GetLateAttendanceReportResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        record {|
            int? id;
        |}? person;
        int? activity_instance_id;
        string? sign_in_time;
        string? sign_out_time;
        string? in_marked_by;
        string? out_marked_by;
        string? preferred_name;
        string? digital_id;
        int? person_id;
    |}[]? late_attendance_report;
|};

public type CreateDutyEvaluationResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        int? evaluatee_id;
        int? evaluator_id;
        int? evaluation_criteria_id;
        int? activity_instance_id;
        string? response;
        string? notes;
        int? grade;
        string? created;
    |}? add_duty_evaluation;
|};

public type GetAttendanceMissedBySecurityByOrgResponse record {|
    map<json?> __extensions?;
    record {|
        string? preferred_name;
        string? digital_id;
        string? description;
        string? sign_in_time;
    |}[]? attendance_missed_by_security;
|};

public type GetAttendanceMissedBySecurityByParentOrgResponse record {|
    map<json?> __extensions?;
    record {|
        string? preferred_name;
        string? digital_id;
        string? description;
        string? sign_in_time;
    |}[]? attendance_missed_by_security;
|};

public type GetDailyStudentsAttendanceByParentOrgResponse record {|
    map<json?> __extensions?;
    record {|
        string? description;
        int? present_count;
        int? total_student_count;
        string? svg_src;
        string? color;
    |}[]? daily_students_attendance_by_parent_org;
|};

public type GetTotalAttendanceCountByDateByOrgResponse record {|
    map<json?> __extensions?;
    record {|
        string? attendance_date;
        int? daily_total;
    |}[]? total_attendance_count_by_date;
|};

public type GetTotalAttendanceCountByParentOrgResponse record {|
    map<json?> __extensions?;
    record {|
        string? attendance_date;
        int? daily_total;
    |}[]? total_attendance_count_by_date;
|};

public type GetDailyAttendanceSummaryReportResponse record {|
    map<json?> __extensions?;
    record {|
        string? sign_in_date;
        int? present_count;
        int? late_count;
        int? total_count;
        anydata? present_attendance_percentage;
        anydata? late_attendance_percentage;
    |}[]? daily_attendance_summary_report;
|};

public type GetOrganizationsByAvinyaTypeResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        record {|
            string name_en;
        |} name;
        string? description;
        record {|
            string? key_name;
            string? value;
        |}[]? organization_metadata;
    |}[]? organizations_by_avinya_type;
|};
