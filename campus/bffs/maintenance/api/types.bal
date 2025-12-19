import ballerina/http;
public type ApiErrorResponse record {|
    *http:BadRequest;
    record {
        string message;
    } body;
|};

public type ApiInternalServerError record {|
    *http:InternalServerError;
    record {
        string message;
    } body;
|};

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

public type ErrorDetail record {
    string message;
    int errorCode;
    int statusCode;
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

public type ActivityInstance record {
    string? notes?;
    string? created?;
    int? weekly_sequence?;
    string? end_time?;
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
    int? organization_id?;
    int? id?;
    string? updated?;
    int? person_id?;
    string? start_date?;
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

public type OrganizationLocation record {
    string? location_name?;
    int? organization_id?;
    string? description?;
    int? id?;
    string? record_type?;
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
    |}[] locationsByOrganization;
|};

public type GetEmployeesByOrganizationResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        string? preferred_name;
    |}[] persons;
|};

public type CreateMaintenanceTaskResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
    |}? createMaintenanceTask;
|};
