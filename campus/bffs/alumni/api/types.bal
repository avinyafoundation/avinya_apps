public type Address record {
    string? street_address?;
    string? name_ta?;
    int? phone?;
    string? name_si?;
    int? id?;
    string? record_type?;
    int? city_id?;
    string name_en?;
    City? city?;
};

public type District record {
    string name_en?;
    string? name_ta?;
    string? name_si?;
    int? id?;
    string? record_type?;
    int province_id?;
    Province? province?;
    City[]? cities?;
};

public type Province record {
    string? record_type?;
    int? id?;
    string name_en?;
    string? name_ta?;
    string? name_si?;
};

public type City record {
    string? record_type?;
    int? id?;
    District? district?;
    int district_id?;
    string? name_en?;
    string? name_ta?;
    string? name_si?;
    string? suburb_name_en?;
    string? suburb_name_ta?;
    string? suburb_name_si?;
    string? postcode?;
    anydata? latitude?;
    anydata? longitude?;
};

public type Alumni record {
    string? created?;
    string? company_name?;
    string? updated_by?;
    string? linkedin_id?;
    int? id?;
    string? job_title?;
    string? updated?;
    string? record_type?;
    string? status?;
    string? facebook_id?;
    string? instagram_id?;
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

public type PersonProfilePicture record {
    int? organization_id?;
    int? id?;
    string? picture_id?;
    string? record_type?;
    string? picture?;
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

public type ErrorDetail record {
    string message;
    int errorCode;
};

public type CreateAlumniResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        string? preferred_name;
        string? full_name;
        record {|
            record {|
                int? id;
                record {|
                    string? name_en;
                    string? name_si;
                    string? name_ta;
                |} name;
            |} city;
            string? street_address;
            int? phone;
            int? id;
        |}? mailing_address;
        int? phone;
        string? email;
        int? documents_id;
        int? alumni_id;
    |}? create_alumni;
|};

public type UpdateAlumniResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        string? preferred_name;
        string? full_name;
        record {|
            record {|
                int? id;
                record {|
                    string? name_en;
                    string? name_si;
                    string? name_ta;
                |} name;
            |} city;
            string? street_address;
            int? phone;
            int? id;
        |}? mailing_address;
        int? phone;
        string? email;
        int? documents_id;
        int? alumni_id;
    |}? update_alumni;
|};

public type CreateAlumniEducationQualificationResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        int? person_id;
        string? university_name;
        string? course_name;
        int? is_currently_studying;
        string? start_date;
        string? end_date;
        string? created;
        string? updated;
    |}? create_alumni_education_qualification;
|};

public type CreateAlumniWorkExperienceResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        int? person_id;
        string? company_name;
        string? job_title;
        int? currently_working;
        string? start_date;
        string? end_date;
        string? created;
        string? updated;
    |}? create_alumni_work_experience;
|};

public type UpdateAlumniEducationQualificationResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        int? person_id;
        string? university_name;
        string? course_name;
        int? is_currently_studying;
        string? start_date;
        string? end_date;
        string? created;
        string? updated;
    |}? update_alumni_education_qualification;
|};

public type UpdateAlumniWorkExperienceResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        int? person_id;
        string? company_name;
        string? job_title;
        int? currently_working;
        string? start_date;
        string? end_date;
        string? created;
        string? updated;
    |}? update_alumni_work_experience;
|};

public type GetAlumniEducationQualificationByIdResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        int? person_id;
        string? university_name;
        string? course_name;
        int? is_currently_studying;
        string? start_date;
        string? end_date;
    |}? alumni_education_qualification_by_id;
|};

public type GetAlumniWorkExperienceByIdResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        int? person_id;
        string? company_name;
        string? job_title;
        int? currently_working;
        string? start_date;
        string? end_date;
    |}? alumni_work_experience_by_id;
|};

public type GetAlumniPersonByIdResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        string? preferred_name;
        string? full_name;
        string? date_of_birth;
        record {|
            record {|
                int? id;
                record {|
                    string? name_en;
                    string? name_si;
                    string? name_ta;
                |} name;
                record {|
                    int? id;
                    record {|
                        string? name_en;
                    |} name;
                |} district;
            |} city;
            string? street_address;
            int? phone;
            int? id;
        |}? mailing_address;
        int? phone;
        record {|
            int? id;
            string? description;
            string? notes;
            record {|
                int? id;
            |}? address;
            record {|
                int? id;
                string? name;
            |}? avinya_type;
            record {|
                string? name_en;
            |} name;
            record {|
                int? id;
                record {|
                    string? name_en;
                |} name;
            |}[]? parent_organizations;
        |}? organization;
        string? nic_no;
        string? id_no;
        string? email;
        record {|
            int? id;
            string? status;
            string? company_name;
            string? job_title;
            string? linkedin_id;
            string? facebook_id;
            string? instagram_id;
        |}? alumni;
        record {|
            int? id;
            int? person_id;
            string? university_name;
            string? course_name;
            int? is_currently_studying;
            string? start_date;
            string? end_date;
        |}[]? alumni_education_qualifications;
        record {|
            int? id;
            int? person_id;
            string? company_name;
            string? job_title;
            int? currently_working;
            string? start_date;
            string? end_date;
        |}[]? alumni_work_experience;
    |}? person_by_id;
|};
