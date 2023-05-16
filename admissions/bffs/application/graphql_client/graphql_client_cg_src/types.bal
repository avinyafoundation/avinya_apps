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
    int[]? child_student?;
    string? bank_account_name?;
    int? avinya_phone?;
    string? full_name?;
    string? nic_no?;
    int? phone?;
    int? organization_id?;
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

public type CreateStudentApplicantResponse record {|
    map<json?> __extensions?;
    record {|
        string? asgardeo_id;
        string? preferred_name;
        string? full_name;
        string? sex;
        record {|record {|
                string name_en;
            |} name;|}? organization;
        int? phone;
        string? email;
        record {|
            string street_address;
            record {|record {|
                    string name_en;
                |} name;|} city;
            int? phone;
        |}? permanent_address;
        record {|
            string street_address;
            record {|record {|
                    string name_en;
                |} name;|} city;
            int? phone;
        |}? mailing_address;
        string? notes;
        string? date_of_birth;
        record {|
            string? name;
            boolean active;
            string global_type;
            string? foundation_type;
            string? focus;
            int? level;
        |}? avinya_type;
        string? passport_no;
        string? nic_no;
        string? id_no;
    |}? add_student_applicant;
|};

public type CreateStudentApplicantConsentResponse record {|
    map<json?> __extensions?;
    record {|
        string? name;
        string? date_of_birth;
        boolean? done_ol;
        int? ol_year;
        int? distance_to_school;
        int? phone;
        string? email;
        boolean? information_correct_consent;
        boolean? agree_terms_consent;
    |}? add_student_applicant_consent;
|};

public type GetOrganizationVacanciesResponse record {|
    map<json?> __extensions?;
    record {|record {|
            record {|
                string name_en;
            |} name;
            record {|
                string street_address;
            |}? address;
            record {|
                string? name;
                boolean active;
                string global_type;
                string? foundation_type;
                string? focus;
                int? level;
            |}? avinya_type;
            int? phone;
            record {|record {|
                    string name_en;
                |} name; record {|
                    string? name;
                    string? description;
                    int? head_count;
                    record {|
                        string? name;
                        boolean active;
                        string global_type;
                        string? foundation_type;
                        string? focus;
                        int? level;
                    |}? avinya_type;
                    record {|
                        string? prompt;
                        string? description;
                        string? difficulty;
                        string? evaluation_type;
                        int? rating_out_of;
                        record {|
                            string? answer;
                        |}[]? answer_options;
                    |}[]? evaluation_criteria;
                |}[]? vacancies;|}[]? child_organizations;
            record {|record {|
                    string name_en;
                |} name;|}[]? parent_organizations;
            record {|
                string? name;
                string? description;
                int? head_count;
            |}[]? vacancies;
        |}[]? organizations;|}? organization_structure;
|};

public type CreateProspectResponse record {|
    map<json?> __extensions?;
    record {|
        string? name;
        int? phone;
        string? email;
        boolean? receive_information_consent;
        boolean? agree_terms_consent;
        string? created;
    |}? add_prospect;
|};

public type CreateStudentApplicationResponse record {|
    map<json?> __extensions?;
    record {|record {|
            string? status;
        |}[]? statuses;|}? add_application;
|};

public type GetApplicationResponse record {|
    map<json?> __extensions?;
    record {|
        string? application_date;
        record {|
            string? status;
            string? updated;
        |}[]? statuses;
    |}? application;
|};

public type GetStudentApplicantResponse record {|
    map<json?> __extensions?;
    record {|
        string? asgardeo_id;
        string? full_name;
        string? preferred_name;
        string? email;
        int? phone;
        string? jwt_sub_id;
        string? jwt_email;
    |}? student_applicant;
|};
