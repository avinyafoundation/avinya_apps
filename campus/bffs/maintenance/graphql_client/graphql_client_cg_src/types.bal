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
    MaintenanceFinance? financialInformation?;
    string? created?;
    int? weekly_sequence?;
    string? end_time?;
    MaintenanceTask? maintenanceTask?;
    string? description?;
    int? task_id?;
    int? daily_sequence?;
    string? record_type?;
    int? monthly_sequence?;
    string? start_time?;
    int? organization_id?;
    string? overall_task_status?;
    int? activity_id?;
    string? name?;
    string? location?;
    int? id?;
    string? updated?;
    int? place_id?;
    ActivityParticipant[]? activityParticipants?;
};

public type ActivityInstanceEvaluation record {
    string? feedback?;
    int? activity_instance_id?;
    string? created?;
    int? evaluator_id?;
    int? rating?;
    int? id?;
    string? updated?;
    string? record_type?;
};

public type ActivityParticipant record {
    string? end_date?;
    string? role?;
    string? notes?;
    string? participant_task_status?;
    string? created?;
    int? is_attending?;
    string? record_type?;
    int? activity_instance_id?;
    Person? person?;
    int? organization_id?;
    int? id?;
    string? updated?;
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
    string? street_address?;
    int? phone?;
    City? city?;
    int? id?;
    string? record_type?;
    int? city_id?;
};

public type Alumni record {
    string? created?;
    string? linkedin_id?;
    string? record_type?;
    string? facebook_id?;
    string? instagram_id?;
    string? canva_cv_url?;
    string? company_name?;
    string? tiktok_id?;
    string? updated_by?;
    int? id?;
    string? job_title?;
    int? person_count?;
    string? updated?;
    string? status?;
};

public type AlumniEducationQualification record {
    string? end_date?;
    string? course_name?;
    string? created?;
    int? is_currently_studying?;
    int? id?;
    string? university_name?;
    string? updated?;
    string? record_type?;
    int? person_id?;
    string? start_date?;
};

public type AlumniWorkExperience record {
    string? end_date?;
    string? created?;
    string? company_name?;
    int? id?;
    string? job_title?;
    string? updated?;
    string? record_type?;
    int? person_id?;
    int? currently_working?;
    string? start_date?;
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

public type City record {
    string? suburb_name_en?;
    string? suburb_name_si?;
    string? name_ta?;
    string? suburb_name_ta?;
    anydata? latitude?;
    string? postcode?;
    string? name_si?;
    int? id?;
    int? district_id?;
    string? record_type?;
    string? name_en?;
    anydata? longitude?;
};

public type Consumable record {
    string? created?;
    int? avinya_type_id?;
    string? name?;
    string? description?;
    string? model?;
    string? serial_number?;
    anydata? threshold?;
    int? id?;
    string? updated?;
    string? record_type?;
    string? manufacturer?;
};

public type CvRequest record {
    int? phone?;
    string? created?;
    int? id?;
    string? updated?;
    string? record_type?;
    int? person_id?;
    string? status?;
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
    string? month_name?;
    int? consumable_id?;
    anydata? quantity?;
    string? created?;
    anydata? prev_quantity?;
    int? avinya_type_id?;
    string? description?;
    int? asset_id?;
    int? is_below_threshold?;
    string? record_type?;
    string? manufacturer?;
    anydata? quantity_out?;
    int? resource_property_id?;
    anydata? quantity_in?;
    int? organization_id?;
    string? name?;
    int? id?;
    string? updated?;
    string? resource_property_value?;
    int? person_id?;
};

public type JobPost record {
    string? job_type?;
    string? job_link?;
    string? created?;
    string? application_deadline?;
    string? job_image_drive_id?;
    string? record_type?;
    string? uploaded_by?;
    string? job_text?;
    int? id?;
    int? job_category_id?;
    string? job_post_image?;
    string? job_category?;
    string? updated?;
    string? current_date_time?;
};

public type MaintenanceFinance record {
    int? activity_instance_id?;
    anydata? labour_cost?;
    string? reviewed_by?;
    string? created?;
    anydata? estimated_cost?;
    string? rejection_reason?;
    MaterialCost[]? materialCosts?;
    int? id?;
    string? updated?;
    string? record_type?;
    string? reviewed_date?;
    string? status?;
};

public type MaintenanceTask record {
    boolean? is_active?;
    int? exception_deadline?;
    string? created?;
    int? has_financial_info?;
    string? description?;
    string? title?;
    string? record_type?;
    int? location_id?;
    string? frequency?;
    string? modified_by?;
    int[]? person_id_list?;
    int? id?;
    string? task_type?;
    string? updated?;
    MaintenanceFinance? finance?;
    string? start_date?;
};

public type MaterialCost record {
    string? item?;
    string? unit?;
    int? financial_id?;
    anydata? quantity?;
    anydata? unit_cost?;
    int? id?;
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

public type OrganizationLocation record {
    string? location_name?;
    int? organization_id?;
    string? description?;
    int? id?;
    string? record_type?;
};

public type Person record {
    int? permanent_address_id?;
    string? street_address?;
    string? bank_branch?;
    string? bank_account_number?;
    string? notes?;
    int[]? parent_student?;
    string? date_of_birth?;
    int? parent_organization_id?;
    int? avinya_type_id?;
    Address? permanent_address?;
    boolean? is_graduated?;
    int? mailing_address_id?;
    Alumni? alumni?;
    string? profile_picture_folder_id?;
    string? id_no?;
    string? jwt_email?;
    string? bank_name?;
    int? alumni_id?;
    int? id?;
    string? email?;
    string? created?;
    string? digital_id?;
    string? sex?;
    string? passport_no?;
    string? current_job?;
    int? created_by?;
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
    int? updated_by?;
    string? academy_org_name?;
    string? asgardeo_id?;
    int? documents_id?;
    string? updated?;
    string? preferred_name?;
    string? jwt_sub_id?;
    int? academy_org_id?;
};

public type PersonCv record {
    string? file_content?;
    string? uploaded_by?;
    string? nic_no?;
    string? drive_file_id?;
    string? created?;
    int? id?;
    string? updated?;
    string? record_type?;
    int? person_id?;
};

public type PersonFcmToken record {
    string? created?;
    string? fcm_token?;
    int? id?;
    string? updated?;
    string? record_type?;
    int? person_id?;
};

public type PersonProfilePicture record {
    string? uploaded_by?;
    string? nic_no?;
    string? created?;
    string? profile_picture_drive_id?;
    int? id?;
    string? updated?;
    string? record_type?;
    string? picture?;
    int? person_id?;
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

public type UserDocument record {
    string? birth_certificate_back_id?;
    string? additional_certificate_01_id?;
    string? additional_certificate_02_id?;
    string? nic_back_id?;
    string? document?;
    string? additional_certificate_05_id?;
    string? additional_certificate_04_id?;
    string? additional_certificate_03_id?;
    string? record_type?;
    string? al_certificate_id?;
    string? nic_front_id?;
    string? ol_certificate_id?;
    string? birth_certificate_front_id?;
    int? id?;
    string? folder_id?;
    string? document_type?;
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

public type SaveOrganizationLocationResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        int? organization_id;
        string? location_name;
        string? description;
    |}? saveOrganizationLocation;
|};

public type GetLocationsByOrganizationResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        int? organization_id;
        string? location_name;
        string? description;
    |}[]? locationsByOrganization;
|};

public type GetEmployeesByOrganizationResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        string? preferred_name;
    |}[]? persons;
|};

public type CreateMaintenanceTaskResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
    |}? createMaintenanceTask;
|};

public type MaintenanceTasksResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        string? start_time;
        string? end_time;
        string? overall_task_status;
        record {|
            int? id;
            string? title;
            string? description;
            string? task_type;
            string? frequency;
            int? exception_deadline;
            record {|
                int? id;
                string? location_name;
            |}? location;
        |}? task;
        record {|
            int? id;
            string? participant_task_status;
            record {|
                int? id;
                string? preferred_name;
            |}? person;
        |}[]? activity_participants;
        record {|
            int? id;
            anydata? estimated_cost;
            anydata? labour_cost;
            record {|
                int? id;
                string? item;
                anydata? quantity;
                string? unit;
                anydata? unit_cost;
            |}[]? material_costs;
            string? status;
            string? rejection_reason;
            string? reviewed_by;
            string? reviewed_date;
        |}? finance;
    |}[]? maintenanceTasks;
|};

public type GetOverdueMaintenanceTasksResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        int? task_id;
        string? start_time;
        string? end_time;
        string? overall_task_status;
        int? overdue_days;
        record {|
            int? id;
            string? title;
            string? description;
            string? task_type;
            string? frequency;
            record {|
                int? id;
                string? location_name;
            |}? location;
        |}? task;
        record {|
            int? id;
            string? participant_task_status;
            record {|
                int? id;
                string? preferred_name;
            |}? person;
        |}[]? activity_participants;
    |}[]? overdueMaintenanceTasks;
|};

public type SoftDeactivateMaintenanceTaskResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        string? modified_by;
    |}? softDeactivateMaintenanceTask;
|};

public type UpdateMaintenanceFinanceResponse record {|
    map<json?> __extensions?;
    record {|
        string? status;
        string? rejection_reason;
        string? reviewed_by;
    |}? updateMaintenanceFinance;
|};

public type GetMonthlyMaintenanceReportResponse record {|
    map<json?> __extensions?;
    record {|
        int? totalTasks;
        int? completedTasks;
        int? inProgressTasks;
        int? pendingTasks;
        anydata? totalCosts;
        int? totalUpcomingTasks;
        anydata? nextMonthlyEstimatedCost;
    |} monthlyMaintenanceReport;
|};

public type MaintenanceTasksByStatusResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        string? start_time;
        string? end_time;
        string? overall_task_status;
        record {|
            int? id;
            string? title;
            string? description;
            string? task_type;
            string? frequency;
            int? exception_deadline;
            record {|
                int? id;
                string? location_name;
            |}? location;
        |}? task;
        record {|
            int? id;
            string? participant_task_status;
            record {|
                int? id;
                string? preferred_name;
            |}? person;
        |}[]? activity_participants;
    |}[]? maintenanceTasksByMonthYearStatus;
|};

public type MonthlyTaskCostReportResponse record {|
    map<json?> __extensions?;
    record {|
        int organizationId;
        int year;
        int month;
        anydata totalActualCost;
        anydata totalEstimatedCost;
        record {|
            int taskId;
            string taskTitle;
            anydata actualCost;
            anydata estimatedCost;
        |}[] tasks;
    |} monthlyTaskCostReport;
|};

public type UpdateMaintenanceTaskResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        string? start_time;
        string? end_time;
        string? overall_task_status;
        record {|
            int? id;
            string? title;
            string? description;
            string? task_type;
            string? frequency;
            int? exception_deadline;
            record {|
                int? id;
                string? location_name;
            |}? location;
        |}? task;
        record {|
            int? id;
            string? participant_task_status;
            record {|
                int? id;
                string? preferred_name;
            |}? person;
        |}[]? activity_participants;
        record {|
            int? id;
            anydata? estimated_cost;
            anydata? labour_cost;
            record {|
                int? id;
                string? item;
                anydata? quantity;
                string? unit;
                anydata? unit_cost;
            |}[]? material_costs;
            string? status;
            string? rejection_reason;
            string? reviewed_by;
            string? reviewed_date;
        |}? finance;
    |}? updateMaintenanceTask;
|};
