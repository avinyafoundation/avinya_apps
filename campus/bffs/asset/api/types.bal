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

// public type Inventory record {
//     int? consumable_id?;
//     anydata? quantity?;
//     string? created?;
//     int? avinya_type_id?;
//     string? description?;
//     int? asset_id?;
//     string? record_type?;
//     string? manufacturer?;
//     anydata? quantity_out?;
//     int? resource_property_id?;
//     anydata? quantity_in?;
//     int? organization_id?;
//     string? name?;
//     int? id?;
//     string? updated?;
//     string? resource_property_value?;
//     int? person_id?;
// };
public type Inventory record {
    int? consumable_id?;
    decimal? quantity?;
    string? created?;
    int? avinya_type_id?;
    string? description?;
    int? asset_id?;
    string? record_type?;
    string? manufacturer?;
    decimal? quantity_out?;
    int? resource_property_id?;
    decimal? quantity_in?;
    int? organization_id?;
    string? name?;
    int? id?;
    string? updated?;
    string? resource_property_value?;
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

public type GetAssetResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        string? name;
        string? manufacturer;
        string? model;
        string? serial_number;
        string? registration_number;
        string? description;
        int? avinya_type_id;
        record {|
            int? id;
        |}? avinya_type;
    |}[]? asset;
|};

public type GetAssetsResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        string? name;
        string? manufacturer;
        string? model;
        string? serial_number;
        string? registration_number;
        string? description;
        int? avinya_type_id;
        record {|
            int? id;
        |}? avinya_type;
    |}[] assets;
|};

public type CreateAssetResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        string? name;
        string? manufacturer;
        string? model;
        string? serial_number;
        string? registration_number;
        string? description;
        record {|
            int? id;
        |}? avinya_type;
    |}? add_asset;
|};

public type UpdateAssetResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        string? name;
        string? manufacturer;
        string? model;
        string? serial_number;
        string? registration_number;
        string? description;
        record {|
            int? id;
        |}? avinya_type;
    |}? update_asset;
|};

public type GetSupplierResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        string? name;
        string? description;
        int? phone;
        string? email;
        record {|
            int? id;
        |}? address;
    |}? supplier;
|};

public type GetSuppliersResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        string? name;
        string? description;
        int? phone;
        string? email;
        record {|
            int? id;
        |}? address;
    |}[] suppliers;
|};

public type AddSupplierResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        string? name;
        string? description;
        int? phone;
        string? email;
        record {|
            int? id;
        |}? address;
    |}? add_supplier;
|};

public type UpdateSupplierResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        string? name;
        string? description;
        int? phone;
        string? email;
        record {|
            int? id;
        |}? address;
    |}? update_supplier;
|};

public type GetConsumableResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        record {|
            int? id;
        |}? avinya_type;
        string? name;
        string? description;
        string? manufacturer;
        string? model;
        string? serial_number;
    |}? consumable;
|};

public type GetConsumablesResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        record {|
            int? id;
        |}? avinya_type;
        string? name;
        string? description;
        string? manufacturer;
        string? model;
        string? serial_number;
    |}[] consumables;
|};

public type AddConsumableResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        record {|
            int? id;
        |}? avinya_type;
        string? name;
        string? description;
        string? manufacturer;
        string? model;
        string? serial_number;
    |}? add_consumable;
|};

public type UpdateConsumableResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        record {|
            int? id;
        |}? avinya_type;
        string? name;
        string? description;
        string? manufacturer;
        string? model;
        string? serial_number;
    |}? update_consumable;
|};

public type GetResourcePropertyResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        record {|
            int? id;
        |}? asset;
        record {|
            int? id;
        |}? consumable;
        string? property;
        string? value;
    |}? resource_property;
|};

public type GetResourcePropertiesResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        record {|
            int? id;
        |}? asset;
        record {|
            int? id;
        |}? consumable;
        string? property;
        string? value;
    |}[] resource_properties;
|};

public type AddResourcePropertyResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        record {|
            int? id;
        |}? asset;
        record {|
            int? id;
        |}? consumable;
        string? property;
        string? value;
    |}? add_resource_property;
|};

public type UpdateResourcePropertyResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        record {|
            int? id;
        |}? asset;
        record {|
            int? id;
        |}? consumable;
        string? property;
        string? value;
    |}? update_resource_property;
|};

public type GetSupplyResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        record {|
            int? id;
        |}? asset;
        record {|
            int? id;
        |}? consumable;
        record {|
            int? id;
        |}? supplier;
        record {|
            int? id;
        |}? person;
        string? order_date;
        string? delivery_date;
        string? order_id;
        int? order_amount;
    |}? supply;
|};

public type GetSuppliesResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        record {|
            int? id;
        |}? asset;
        record {|
            int? id;
        |}? consumable;
        record {|
            int? id;
        |}? supplier;
        record {|
            int? id;
        |}? person;
        string? order_date;
        string? delivery_date;
        string? order_id;
        int? order_amount;
    |}[] supplies;
|};

public type AddSupplyResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        record {|
            int? id;
        |}? asset;
        record {|
            int? id;
        |}? consumable;
        record {|
            int? id;
        |}? supplier;
        record {|
            int? id;
        |}? person;
        string? order_date;
        string? delivery_date;
        string? order_id;
        int? order_amount;
    |}? add_supply;
|};

public type UpdateSupplyResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        record {|
            int? id;
        |}? asset;
        record {|
            int? id;
        |}? consumable;
        record {|
            int? id;
        |}? supplier;
        record {|
            int? id;
        |}? person;
        string? order_date;
        string? delivery_date;
        string? order_id;
        int? order_amount;
    |}? update_supply;
|};

public type GetResourceAllocationResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        boolean? requested;
        boolean? approved;
        boolean? allocated;
        record {|
            int? id;
        |}? asset;
        record {|
            int? id;
        |}? consumable;
        record {|
            int? id;
        |}? organization;
        record {|
            int? id;
        |}? person;
        int? quantity;
        string? start_date;
        string? end_date;
    |}[] resource_allocation;
|};

public type GetResourceAllocationByPersonResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        boolean? requested;
        boolean? approved;
        boolean? allocated;
        record {|
            int? id;
            string? name;
            string? manufacturer;
            string? model;
            string? serial_number;
            string? registration_number;
            string? description;
            record {|
                int? id;
            |}? avinya_type;
        |}? asset;
        record {|
            int? id;
        |}? consumable;
        record {|
            int? id;
        |}? organization;
        record {|
            int? id;
        |}? person;
        int? quantity;
        string? start_date;
        string? end_date;
    |}[] resource_allocation;
|};

public type GetResourceAllocationsResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        boolean? requested;
        boolean? approved;
        boolean? allocated;
        record {|
            int? id;
        |}? asset;
        record {|
            int? id;
        |}? consumable;
        record {|
            int? id;
        |}? organization;
        record {|
            int? id;
        |}? person;
        int? quantity;
        string? start_date;
        string? end_date;
    |}[] resource_allocations;
|};

public type AddResourceAllocationResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        boolean? requested;
        boolean? approved;
        boolean? allocated;
        record {|
            int? id;
        |}? asset;
        record {|
            int? id;
        |}? consumable;
        record {|
            int? id;
        |}? organization;
        record {|
            int? id;
        |}? person;
        int? quantity;
        string? start_date;
        string? end_date;
    |}? add_resource_allocation;
|};

public type UpdateResourceAllocationResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        boolean? requested;
        boolean? approved;
        boolean? allocated;
        record {|
            int? id;
        |}? asset;
        record {|
            int? id;
        |}? consumable;
        record {|
            int? id;
        |}? organization;
        record {|
            int? id;
        |}? person;
        int? quantity;
        string? start_date;
        string? end_date;
    |}? update_resource_allocation;
|};

public type GetInventoryResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        record {|
            int? id;
        |}? asset;
        record {|
            int? id;
        |}? consumable;
        record {|
            int? id;
        |}? organization;
        record {|
            int? id;
        |}? person;
        record {|
            int? id;
            boolean active;
            string? description;
            string? focus;
            string? foundation_type;
            string global_type;
            int? level;
            string? name;
        |}? avinya_type;
        int? avinya_type_id;
        anydata? quantity;
        anydata? quantity_in;
        anydata? quantity_out;
    |}? inventory;
|};

public type GetInventoriesResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        record {|
            int? id;
        |}? asset;
        record {|
            int? id;
        |}? consumable;
        record {|
            int? id;
        |}? organization;
        record {|
            int? id;
        |}? person;
        record {|
            int? id;
            boolean active;
            string? description;
            string? focus;
            string? foundation_type;
            string global_type;
            int? level;
            string? name;
        |}? avinya_type;
        int? avinya_type_id;
        anydata? quantity;
        anydata? quantity_in;
        anydata? quantity_out;
    |}[] inventories;
|};

public type AddInventoryResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        record {|
            int? id;
        |}? asset;
        record {|
            int? id;
        |}? consumable;
        record {|
            int? id;
        |}? organization;
        record {|
            int? id;
        |}? person;
        record {|
            int? id;
        |}? avinya_type;
        anydata? quantity;
        anydata? quantity_in;
        anydata? quantity_out;
    |}? add_inventory;
|};

public type UpdateInventoryResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        record {|
            int? id;
        |}? asset;
        record {|
            int? id;
        |}? consumable;
        record {|
            int? id;
        |}? organization;
        record {|
            int? id;
        |}? person;
        record {|
            int? id;
        |}? avinya_type;
        anydata? quantity;
        anydata? quantity_in;
        anydata? quantity_out;
    |}? update_inventory;
|};

public type GetAssetByAvinyaTypeResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        string? name;
        string? model;
        string? manufacturer;
        string? description;
        string? registration_number;
        string? serial_number;
        int? avinya_type_id;
        record {|
            int? id;
        |}? avinya_type;
    |}[] asset_by_avinya_type;
|};

public type GetAvinyaTypeByAssetResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        string? name;
        string global_type;
        string? foundation_type;
        string? description;
        string? focus;
        boolean active;
        int? level;
    |}[] avinya_types_by_asset;
|};

public type GetResourceAllocationReportResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        boolean? requested;
        boolean? approved;
        boolean? allocated;
        record {|
            int? id;
            string? name;
            string? manufacturer;
            string? model;
            string? serial_number;
            string? registration_number;
            string? description;
        |}? asset;
        record {|
            string? property;
            string? value;
        |}[] resource_properties;
        record {|
            int? id;
            string? description;
            record {|
                string name_en;
            |} name;
        |}? organization;
        record {|
            int? id;
            string? preferred_name;
            string? digital_id;
        |}? person;
        int? quantity;
        string? start_date;
        string? end_date;
    |}[] resource_allocations_report;
|};

public type GetOrganizationsByAvinyaTypeResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        record {|
            string name_en;
        |} name;
        string? description;
    |}[] organizations_by_avinya_type;
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
        string? description;
    |}[] avinya_types;
|};

public type GetInventoryDataByOrganizationResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        record {|
            int? id;
            string global_type;
            string? name;
        |}? avinya_type;
        string? name;
        string? manufacturer;
        string? description;
        anydata? quantity;
        anydata? quantity_in;
        anydata? quantity_out;
        record {|
            int? id;
            string? property;
            string? value;
        |}? resource_property;
    |}[] inventory_data_by_organization;
|};

public type GetConsumableWeeklyReportResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        record {|
            int? id;
            string global_type;
            string? name;
        |}? avinya_type;
        record {|
            int? id;
            string? name;
            string? description;
            string? manufacturer;
        |}? consumable;
        anydata? quantity;
        anydata? quantity_in;
        anydata? quantity_out;
        record {|
            int? id;
            string? property;
            string? value;
        |}? resource_property;
        string? updated;
    |}[] consumable_weekly_report;
|};

public type GetConsumableMonthlyReportResponse record {|
    map<json?> __extensions?;
    record {|
        record {|
            int? id;
            string? name;
            string? description;
            string? manufacturer;
        |}? consumable;
        anydata? quantity_in;
        anydata? quantity_out;
        record {|
            int? id;
            string? property;
            string? value;
        |}? resource_property;
    |}[] consumable_monthly_report;
|};