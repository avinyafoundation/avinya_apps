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

public type Inventory record {
    int? quantity_out?;
    int? consumable_id?;
    int? quantity?;
    int? quantity_in?;
    string? created?;
    int? organization_id?;
    int? id?;
    int? asset_id?;
    string? updated?;
    string? record_type?;
    int? person_id?;
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
    string? notes?;
    int[]? parent_student?;
    string? date_of_birth?;
    int? avinya_type_id?;
    Address? permanent_address?;
    int? mailing_address_id?;
    string? id_no?;
    string? jwt_email?;
    int? id?;
    string? email?;
    string? created?;
    string? sex?;
    string? passport_no?;
    string? record_type?;
    Address? mailing_address?;
    int[]? child_student?;
    string? full_name?;
    string? nic_no?;
    int? phone?;
    int? organization_id?;
    string? asgardeo_id?;
    string? updated?;
    string? preferred_name?;
    string? jwt_sub_id?;
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
    int? organization_id?;
    int? id?;
    int? asset_id?;
    string? updated?;
    string? record_type?;
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

public type GetPctiInstanceNotesResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        int? evaluatee_id;
        int? evaluator_id;
        int? evaluation_criteria_id;
        string? updated;
        string? notes;
        int? grade;
        record {|
            int? id;
            int? evaluatee_id;
            int? evaluator_id;
            int? evaluation_criteria_id;
            string? updated;
            string? notes;
            int? grade;
        |}[]? child_evaluations;
        record {|
            int? id;
            int? evaluatee_id;
            int? evaluator_id;
            int? evaluation_criteria_id;
            string? updated;
            string? notes;
            int? grade;
        |}[]? parent_evaluations;
    |}[]? pcti_instance_notes;
|};

public type GetPctiNotesResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        int? evaluatee_id;
        int? evaluator_id;
        int? evaluation_criteria_id;
        string? updated;
        string? notes;
        int? grade;
        record {|
            int? id;
            int? evaluatee_id;
            int? evaluator_id;
            int? evaluation_criteria_id;
            string? updated;
            string? notes;
            int? grade;
        |}[]? child_evaluations;
        record {|
            int? id;
            int? evaluatee_id;
            int? evaluator_id;
            int? evaluation_criteria_id;
            string? updated;
            string? notes;
            int? grade;
        |}[]? parent_evaluations;
    |}[]? pcti_notes;
|};

public type GetActivityResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        string? name;
        string? description;
        record {|
            int? id;
            boolean active;
            string global_type;
            string? name;
            string? foundation_type;
            string? focus;
            int? level;
            string? description;
        |}? avinya_type;
        string? notes;
        record {|
            int? id;
            string? name;
            string? description;
            record {|
                int? id;
                boolean active;
                string global_type;
                string? name;
                string? foundation_type;
                string? focus;
                int? level;
                string? description;
            |}? avinya_type;
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
        record {|
            int? id;
            string? name;
            string? description;
            record {|
                int? id;
                boolean active;
                string global_type;
                string? name;
                string? foundation_type;
                string? focus;
                int? level;
                string? description;
            |}? avinya_type;
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
        |}[]? parent_activities;
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
    |}? activity;
|};

public type AddActivityResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        string? name;
        string? description;
        record {|
            int? id;
            boolean active;
            string global_type;
            string? name;
            string? foundation_type;
            string? focus;
            int? level;
            string? description;
        |}? avinya_type;
        string? notes;
        record {|
            int? id;
            string? name;
            string? description;
            record {|
                int? id;
                boolean active;
                string global_type;
                string? name;
                string? foundation_type;
                string? focus;
                int? level;
                string? description;
            |}? avinya_type;
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
        record {|
            int? id;
            string? name;
            string? description;
            record {|
                int? id;
                boolean active;
                string global_type;
                string? name;
                string? foundation_type;
                string? focus;
                int? level;
                string? description;
            |}? avinya_type;
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
        |}[]? parent_activities;
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
    |}? add_activity;
|};

public type AddActivityInstanceResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        string? name;
        string? description;
        int? activity_id;
        string? notes;
        int? daily_sequence;
        int? weekly_sequence;
        int? monthly_sequence;
        string? start_time;
        string? end_time;
        string? created;
        string? updated;
        record {|
            int? id;
            int? activity_instance_id;
            record {|
                string? preferred_name;
            |}? person;
            record {|
                int? id;
                record {|
                    string name_en;
                |} name;
            |}? organization;
            string? start_date;
            string? end_date;
            string? role;
            string? notes;
            string? created;
            string? updated;
        |}[]? activity_participants;
        record {|
            int? id;
            int? activity_instance_id;
            record {|
                string? preferred_name;
            |}? person;
            string? sign_in_time;
            string? sign_out_time;
            string? created;
            string? updated;
        |}[]? activity_participant_attendances;
        record {|
            int? id;
            int? evaluatee_id;
            int? evaluator_id;
            int? evaluation_criteria_id;
            string? updated;
            string? notes;
            int? grade;
            record {|
                int? id;
                int? evaluatee_id;
                int? evaluator_id;
                int? evaluation_criteria_id;
                string? updated;
                string? notes;
                int? grade;
            |}[]? child_evaluations;
            record {|
                int? id;
                int? evaluatee_id;
                int? evaluator_id;
                int? evaluation_criteria_id;
                string? updated;
                string? notes;
                int? grade;
            |}[]? parent_evaluations;
        |}[]? evaluations;
    |}? add_activity_instance;
|};

public type AddPctiNotesResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        int? evaluatee_id;
        int? evaluator_id;
        int? evaluation_criteria_id;
        string? updated;
        string? notes;
        int? grade;
        record {|
            int? id;
            int? evaluatee_id;
            int? evaluator_id;
            int? evaluation_criteria_id;
            string? updated;
            string? notes;
            int? grade;
        |}[]? child_evaluations;
        record {|
            int? id;
            int? evaluatee_id;
            int? evaluator_id;
            int? evaluation_criteria_id;
            string? updated;
            string? notes;
            int? grade;
        |}[]? parent_evaluations;
    |}? add_pcti_notes;
|};
