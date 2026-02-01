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

public type Organization record {
    int[]? parent_organizations?;
    string? name_ta?;
    int[]? child_organizations?;
    int? phone?;
    int? address_id?;
    string? name_si?;
    int? avinya_type_id?;
    int? id?;
    string? record_type?;
    string? name_en?;
    string? description?;
    string? notes?;
    Address? address?;
    AvinyaType? avinya_type?;
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

public type Province record {
    string? record_type?;
    int? id?;
    string name_en?;
    string? name_ta?;
    string? name_si?;
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

public type Alumni record {
    string? created?;
    string? linkedin_id?;
    string? record_type?;
    string? facebook_id?;
    string? instagram_id?;
    string? company_name?;
    string? tiktok_id?;
    string? updated_by?;
    int? id?;
    string? job_title?;
    int? person_count?;
    string? updated?;
    string? status?;
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

public type GetPersonsResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        string? preferred_name;
        string? full_name;
        string? date_of_birth;
        string? sex;
        string? asgardeo_id;
        string? jwt_sub_id;
        string? created;
        string? updated;
        string? jwt_email;
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
        |}? permanent_address;
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
        int? avinya_type_id;
        string? notes;
        string? nic_no;
        string? passport_no;
        string? id_no;
        string? email;
        string? street_address;
        string? digital_id;
        int? avinya_phone;
        string? bank_name;
        string? bank_account_number;
        string? bank_account_name;
        int? academy_org_id;
        string? bank_branch;
        int? created_by;
        int? updated_by;
        string? current_job;
    |}[] persons;
|};

public type GetPersonByIdResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        string? preferred_name;
        string? full_name;
        string? date_of_birth;
        string? sex;
        string? asgardeo_id;
        string? jwt_sub_id;
        string? created;
        string? updated;
        string? jwt_email;
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
        int? avinya_type_id;
        string? notes;
        string? nic_no;
        string? passport_no;
        string? id_no;
        string? email;
        string? street_address;
        string? digital_id;
        int? avinya_phone;
        string? bank_name;
        string? bank_account_number;
        string? bank_account_name;
        int? academy_org_id;
        string? bank_branch;
        int? created_by;
        int? updated_by;
        string? current_job;
        int? documents_id;
    |}? person_by_id;
|};

public type UpdatePersonResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        string? preferred_name;
        string? full_name;
        string? date_of_birth;
        string? sex;
        string? asgardeo_id;
        string? jwt_sub_id;
        string? created;
        string? updated;
        string? jwt_email;
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
        |}? permanent_address;
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
        int? avinya_type_id;
        string? notes;
        string? nic_no;
        string? passport_no;
        string? id_no;
        string? email;
        string? street_address;
        string? digital_id;
        int? avinya_phone;
        string? bank_name;
        string? bank_account_number;
        string? bank_account_name;
        int? academy_org_id;
        string? bank_branch;
        int? created_by;
        int? updated_by;
        string? current_job;
        int? documents_id;
    |}? update_person;
|};

public type GetDistrictsResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        record {|
            int? id;
            record {|
                string? name_en;
            |} name;
        |} province;
        record {|
            string? name_en;
        |} name;
    |}[] districts;
|};

public type GetCitiesResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        record {|
            string? name_en;
        |} name;
    |}[] cities;
|};
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

public type GetAllOrganizationsResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        record {|
            string? name_en;
        |} name;
        record {|
            int? id;
            string? street_address;
        |}? address;
        record {|
            int? id;
            string? name;
        |}? avinya_type;
        string? description;
        int? phone;
        string? notes;
    |}[] all_organizations;
|};

public type InsertPersonResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        string? preferred_name;
        string? full_name;
        string? date_of_birth;
        string? sex;
        string? asgardeo_id;
        string? jwt_sub_id;
        string? created;
        string? updated;
        string? jwt_email;
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
        |}? permanent_address;
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
        int? avinya_type_id;
        string? notes;
        string? nic_no;
        string? passport_no;
        string? id_no;
        string? email;
        string? street_address;
        string? digital_id;
        int? avinya_phone;
        string? bank_name;
        string? bank_account_number;
        string? bank_account_name;
        int? academy_org_id;
        string? bank_branch;
        int? created_by;
        int? updated_by;
        string? current_job;
        int? documents_id;
    |}? insert_person;
|};
public type UploadDocumentResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        string? folder_id;
        string? nic_front_id;
        string? nic_back_id;
        string? birth_certificate_front_id;
        string? birth_certificate_back_id;
        string? ol_certificate_id;
        string? al_certificate_id;
        string? additional_certificate_01_id;
        string? additional_certificate_02_id;
        string? additional_certificate_03_id;
        string? additional_certificate_04_id;
        string? additional_certificate_05_id;
    |}? upload_document;
|};

public type GetAllDocumentsResponse record {|
    map<json?> __extensions?;
    record {|
        string? document;
        string? document_type;
    |}[] document_list;
|};
