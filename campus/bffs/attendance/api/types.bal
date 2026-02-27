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
    string? in_marked_by?;
    string? created?;
    string? sign_in_time?;
    int? id?;
    string? out_marked_by?;
    string? updated?;
    string? record_type?;
    string? event_time?;
    int? person_id?;
    string? sign_out_time?;
};
public type ActivityParticipantAttendanceForLateAttendance record {|
    readonly string? record_type = "activity_participant_attendance";
    int id?;
    int? person_id;
    int? activity_instance_id;
    string? sign_in_time;
    string? sign_out_time;
    string? in_marked_by;
    string? out_marked_by;
    string? created;
    string? updated;
    string? description;
    string? preferred_name;
    string? digital_id;
    string? label; //The label for the time range (e.g."07:30 - 07:45")
    int studentCount; // Total number of unique students in this range(e.g."07:30 - 07:45")
    string? studentNames; //List of names of students who signed in during this range
|};

public type ActivityParticipantAttendanceSummary record {
    string? sign_in_date;
    int? present_count;
    int? late_count;
    int? total_count;
    decimal? present_attendance_percentage;
    decimal? late_attendance_percentage;
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
    string? notes?;
    string? name_ta?;
    int[]? child_organizations?;
    int? address_id?;
    string? name_si?;
    int? avinya_type?;
    string? description?;
    int? active?;
    int[]? child_organizations_for_dashboard?;
    string? record_type?;
    int[]? parent_organizations?;
    int? phone?;
    int? id?;
    string? name_en?;
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

public type DailyActivityParticipantAttendanceByParentOrg record {
    string? description;
    int? present_count;
    string? svg_src;
    string? color;
    string? record_type?;
    int? total_student_count;
};

public type  TotalAttendanceCountByDate  record {
    string? attendance_date;
    int? daily_total;
    string? record_type?;
};

public type MonthlyLeaveDates record {
    int[] leave_dates_list?;
    int? year?;
    int? batch_id?;
    anydata? monthly_payment_amount?;
    string? created?;
    string? record_type?;
    string? leave_dates?;
    int? month?;
    int? total_days_in_month?;
    int? organization_id?;
    int? id?;
    anydata? daily_amount?;
    string? updated?;
};

public type BatchPaymentPlan record {
    string? record_type?;
    int id?;
    int? organization_id;
    int? batch_id;
    anydata? monthly_payment_amount;
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

public type GetLateAttendanceReportResponse record {|
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
        string? preferred_name;
        string? digital_id;
    |}[] late_attendance_report;
|};

public type GetLateAttendanceReportResponseForParentOrg record {|
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
        string? description;
        string? preferred_name;
        string? digital_id;
    |}[] late_attendance_report;
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
    |}[] activities_by_avinya_type;
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
    |}[] duty_attendance_today;
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
    record {|
        record {|
            string title;
            int numOfFiles;
            string svgSrc;
            string color;
            decimal percentage;
        |} attendance_dashboard_data;
    |}[] attendance_dashboard_data_by_date;
|};

public type AttendanceDashboardData record {
    string? title?;
    int? numOfFiles?;
    string? svgSrc?;
    string? color?;
    decimal? percentage?;
};
public type AttendanceDashboardDataMain record {
    AttendanceDashboardData? attendance_dashboard_data?;
};
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
    |}[] attendance_missed_by_security;
|};

public type GetAttendanceMissedBySecurityByParentOrgResponse record {|
    map<json?> __extensions?;
    record {|
        string? preferred_name;
        string? digital_id;
        string? description;
        string? sign_in_time;
    |}[] attendance_missed_by_security;
|};

public type GetDailyStudentsAttendanceByParentOrgResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        string? description;
        int? present_count;
        int? total_student_count;
        string? svg_src;
        string? color;
    |}[] daily_students_attendance_by_parent_org;
|};

public type GetTotalAttendanceCountByDateByOrgResponse record {|
    map<json?> __extensions?;
    record {|
        string? attendance_date;
        int? daily_total;
    |}[] total_attendance_count_by_date;
|};

public type GetTotalAttendanceCountByParentOrgResponse record {|
    map<json?> __extensions?;
    record {|
        string? attendance_date;
        int? daily_total;
    |}[] total_attendance_count_by_date;
|};

public type GetDailyAttendanceSummaryReportResponse record {|
    map<json?> __extensions?;
    record {|
        string? sign_in_date;
        int? present_count;
        int? absent_count;
        int? late_count;
        int? total_count;
        anydata? present_attendance_percentage;
        anydata? absent_attendance_percentage;
        anydata? late_attendance_percentage;
    |}[] daily_attendance_summary_report;
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
    |}[] organizations_by_avinya_type;
|};

public type CreateMonthlyLeaveDatesResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        int? year;
        int? month;
        int? organization_id;
        int? batch_id;
        int[]? leave_dates_list;
        anydata? daily_amount;
        string? created;
        string? updated;
    |}? add_monthly_leave_dates;
|};

public type UpdateMonthlyLeaveDatesResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        int? year;
        int? month;
        int? organization_id;
        int? batch_id;
        int[]? leave_dates_list;
        anydata? daily_amount;
        string? created;
        string? updated;
    |}? update_monthly_leave_dates;
|};

public type GetMonthlyLeaveDatesRecordByIdResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        int? year;
        int? month;
        int? organization_id;
        int? batch_id;
        int[]? leave_dates_list;
        anydata? daily_amount;
        string? created;
        string? updated;
    |}? monthly_leave_dates_record_by_id;
|};
public type GetOrganizationsByAvinyaTypeWithActiveStatusResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        record {|
            string? name_en;
        |} name;
        string? description;
        record {|
            string? key_name;
            string? value;
        |}[]? organization_metadata;
        int? active;
    |}[] organizations_by_avinya_type;
|};

public type GetBatchPaymentPlanByOrgIdResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        int? organization_id;
        int? batch_id;
        anydata? monthly_payment_amount;
    |} batch_payment_plan_by_org_id;
|};

public type GetOrganizationsByAvinyaTypeAndStatusResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        record {|
            string? name_en;
        |} name;
        string? description;
        record {|
            string? key_name;
            string? value;
        |}[]? organization_metadata;
    |}[] organizations_by_avinya_type_and_status;
|};

public type GetPersonResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        string? full_name;
        string? sex;
        int? phone;
        int? organization_id;
        int? avinya_type_id;
        string? nic_no;
        string? email;
    |}? person_by_digital_id_or_nic;
|};

public type AddBiometricAttendanceResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        int? activity_instance_id;
        string? sign_in_time;
        string? sign_out_time;
        string? created;
    |}? addBiometricAttendance;
|};

public type GetStudentLateAttendanceByTimeRangeResponse record {|
    map<json?> __extensions?;
    record {|
        string? label;
        int? student_count;
        string? student_name;
    |}[] late_attendance_report;
|};

public type GetDailyAbsenceSummaryResponse record {|
    map<json?> __extensions?;
    record {|
        int? absent_count;
        string? absent_names;
    |}[] absent_report;
|};
