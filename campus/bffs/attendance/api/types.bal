public type Activity record {
    string? notes?;
    Activity[]? parent_activities?;
    string? created?;
    string? name?;
    int? avinya_type_id?;
    Activity[]? child_activities?;
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
    string? created?;
    string? sign_in_time?;
    int? id?;
    string? updated?;
    string? record_type?;
    int? person_id?;
    string? sign_out_time?;
    string? in_marked_by?;
    string? out_marked_by?;
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
    string? created?;
    int? avinya_type_id?;
    boolean? agree_terms_consent?;
    boolean? active?;
    boolean? done_ol?;
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

public type Evaluation record {
    int[]? parent_evaluations?;
    int? activity_instance_id?;
    string? notes?;
    int? evaluatee_id?;
    int? evaluation_criteria_id?;
    string? response?;
    int[]? child_evaluations?;
    int? evaluator_id?;
    int? grade?;
    int? id?;
    string? updated?;
    string? record_type?;
};

public type Organization record {
    int[]? parent_organizations?;
    string? name_ta?;
    int[]? child_organizations?;
    int? phone?;
    int? address_id?;
    string? name_si?;
    int? avinya_type?;
    int? id?;
    string? record_type?;
    string name_en?;
};
public type Person record {
    int? permanent_address_id?;
    string? street_address?;
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
    string? bank_branch?;
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

public type DutyParticipant record {
    string? end_date?;
    string? role?;
    string? created?;
    int? activity_id?;
    int? id?;
    string? updated?;
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
        int? person_id;
        string? sign_in_time;
        string? sign_out_time;
        string? created;
        string? updated;
        string? in_marked_by;
        string? out_marked_by;
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
    |}[] activity_instances_today;
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
    |}[] class_attendance_today;
|};

public type GetClassAttendanceReportResponse record {|
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
    |}[] class_attendance_report;
|};

public type GetPersonAttendanceReportResponse record {|
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
    |}[] person_attendance_report;
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
    |}[] person_attendance_today;
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
    |}[] activity_evaluations;
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
    |}[] activity_instance_evaluations;
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
        string? start_date;
        string? end_date;
    |}[] duty_participants;
|};

public type CreateDutyForParticipantResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        int? activity_id;
        int? person_id;
        string? role;
        string? start_date;
        string? end_date;
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
    |}[] activities_by_avinya_type;
|};
