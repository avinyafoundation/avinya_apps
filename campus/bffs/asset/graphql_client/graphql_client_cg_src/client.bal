import ballerina/graphql;

public isolated client class GraphqlClient {
    final graphql:Client graphqlClient;
    public isolated function init(string serviceUrl, ConnectionConfig config = {}) returns graphql:ClientError? {
        graphql:ClientConfiguration graphqlClientConfig = {timeout: config.timeout, forwarded: config.forwarded, poolConfig: config.poolConfig, compression: config.compression, circuitBreaker: config.circuitBreaker, retryConfig: config.retryConfig, validation: config.validation};
        do {
            if config.http1Settings is ClientHttp1Settings {
                ClientHttp1Settings settings = check config.http1Settings.ensureType(ClientHttp1Settings);
                graphqlClientConfig.http1Settings = {...settings};
            }
            if config.cache is graphql:CacheConfig {
                graphqlClientConfig.cache = check config.cache.ensureType(graphql:CacheConfig);
            }
            if config.responseLimits is graphql:ResponseLimitConfigs {
                graphqlClientConfig.responseLimits = check config.responseLimits.ensureType(graphql:ResponseLimitConfigs);
            }
            if config.secureSocket is graphql:ClientSecureSocket {
                graphqlClientConfig.secureSocket = check config.secureSocket.ensureType(graphql:ClientSecureSocket);
            }
            if config.proxy is graphql:ProxyConfig {
                graphqlClientConfig.proxy = check config.proxy.ensureType(graphql:ProxyConfig);
            }
        } on fail var e {
            return <graphql:ClientError>error("GraphQL Client Error", e, body = ());
        }
        graphql:Client clientEp = check new (serviceUrl, graphqlClientConfig);
        self.graphqlClient = clientEp;
    }
    remote isolated function getAsset(int id) returns GetAssetResponse|graphql:ClientError {
        string query = string `query getAsset($id:Int!) {asset(id:$id) {id name manufacturer model serial_number registration_number description avinya_type_id avinya_type {id}}}`;
        map<anydata> variables = {"id": id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetAssetResponse> check performDataBinding(graphqlResponse, GetAssetResponse);
    }
    remote isolated function getAssets() returns GetAssetsResponse|graphql:ClientError {
        string query = string `query getAssets {assets {id name manufacturer model serial_number registration_number description avinya_type_id avinya_type {id}}}`;
        map<anydata> variables = {};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetAssetsResponse> check performDataBinding(graphqlResponse, GetAssetsResponse);
    }
    remote isolated function createAsset(Asset asset) returns CreateAssetResponse|graphql:ClientError {
        string query = string `mutation createAsset($asset:Asset!) {add_asset(asset:$asset) {id name manufacturer model serial_number registration_number description avinya_type {id}}}`;
        map<anydata> variables = {"asset": asset};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <CreateAssetResponse> check performDataBinding(graphqlResponse, CreateAssetResponse);
    }
    remote isolated function updateAsset(Asset asset) returns UpdateAssetResponse|graphql:ClientError {
        string query = string `mutation updateAsset($asset:Asset!) {update_asset(asset:$asset) {id name manufacturer model serial_number registration_number description avinya_type {id}}}`;
        map<anydata> variables = {"asset": asset};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <UpdateAssetResponse> check performDataBinding(graphqlResponse, UpdateAssetResponse);
    }
    remote isolated function getSupplier(int id) returns GetSupplierResponse|graphql:ClientError {
        string query = string `query getSupplier($id:Int!) {supplier(id:$id) {id name description phone email address {id}}}`;
        map<anydata> variables = {"id": id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetSupplierResponse> check performDataBinding(graphqlResponse, GetSupplierResponse);
    }
    remote isolated function getSuppliers() returns GetSuppliersResponse|graphql:ClientError {
        string query = string `query getSuppliers {suppliers {id name description phone email address {id}}}`;
        map<anydata> variables = {};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetSuppliersResponse> check performDataBinding(graphqlResponse, GetSuppliersResponse);
    }
    remote isolated function addSupplier(Supplier supplier) returns AddSupplierResponse|graphql:ClientError {
        string query = string `mutation addSupplier($supplier:Supplier!) {add_supplier(supplier:$supplier) {id name description phone email address {id}}}`;
        map<anydata> variables = {"supplier": supplier};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <AddSupplierResponse> check performDataBinding(graphqlResponse, AddSupplierResponse);
    }
    remote isolated function updateSupplier(Supplier supplier) returns UpdateSupplierResponse|graphql:ClientError {
        string query = string `mutation updateSupplier($supplier:Supplier!) {update_supplier(supplier:$supplier) {id name description phone email address {id}}}`;
        map<anydata> variables = {"supplier": supplier};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <UpdateSupplierResponse> check performDataBinding(graphqlResponse, UpdateSupplierResponse);
    }
    remote isolated function getConsumable(int id) returns GetConsumableResponse|graphql:ClientError {
        string query = string `query getConsumable($id:Int!) {consumable(id:$id) {id avinya_type {id} name description manufacturer model serial_number}}`;
        map<anydata> variables = {"id": id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetConsumableResponse> check performDataBinding(graphqlResponse, GetConsumableResponse);
    }
    remote isolated function getConsumables() returns GetConsumablesResponse|graphql:ClientError {
        string query = string `query getConsumables {consumables {id avinya_type {id} name description manufacturer model serial_number}}`;
        map<anydata> variables = {};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetConsumablesResponse> check performDataBinding(graphqlResponse, GetConsumablesResponse);
    }
    remote isolated function addConsumable(Consumable consumable) returns AddConsumableResponse|graphql:ClientError {
        string query = string `mutation addConsumable($consumable:Consumable!) {add_consumable(consumable:$consumable) {id avinya_type {id} name description manufacturer model serial_number}}`;
        map<anydata> variables = {"consumable": consumable};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <AddConsumableResponse> check performDataBinding(graphqlResponse, AddConsumableResponse);
    }
    remote isolated function updateConsumable(Consumable consumable) returns UpdateConsumableResponse|graphql:ClientError {
        string query = string `mutation updateConsumable($consumable:Consumable!) {update_consumable(consumable:$consumable) {id avinya_type {id} name description manufacturer model serial_number}}`;
        map<anydata> variables = {"consumable": consumable};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <UpdateConsumableResponse> check performDataBinding(graphqlResponse, UpdateConsumableResponse);
    }
    remote isolated function getResourceProperty(int id) returns GetResourcePropertyResponse|graphql:ClientError {
        string query = string `query getResourceProperty($id:Int!) {resource_property(id:$id) {id asset {id} consumable {id} property value}}`;
        map<anydata> variables = {"id": id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetResourcePropertyResponse> check performDataBinding(graphqlResponse, GetResourcePropertyResponse);
    }
    remote isolated function getResourceProperties() returns GetResourcePropertiesResponse|graphql:ClientError {
        string query = string `query getResourceProperties {resource_properties {id asset {id} consumable {id} property value}}`;
        map<anydata> variables = {};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetResourcePropertiesResponse> check performDataBinding(graphqlResponse, GetResourcePropertiesResponse);
    }
    remote isolated function addResourceProperty(ResourceProperty resourceproperty) returns AddResourcePropertyResponse|graphql:ClientError {
        string query = string `mutation addResourceProperty($resourceproperty:ResourceProperty!) {add_resource_property(resourceProperty:$resourceproperty) {id asset {id} consumable {id} property value}}`;
        map<anydata> variables = {"resourceproperty": resourceproperty};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <AddResourcePropertyResponse> check performDataBinding(graphqlResponse, AddResourcePropertyResponse);
    }
    remote isolated function updateResourceProperty(ResourceProperty resourceproperty) returns UpdateResourcePropertyResponse|graphql:ClientError {
        string query = string `mutation updateResourceProperty($resourceproperty:ResourceProperty!) {update_resource_property(resourceProperty:$resourceproperty) {id asset {id} consumable {id} property value}}`;
        map<anydata> variables = {"resourceproperty": resourceproperty};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <UpdateResourcePropertyResponse> check performDataBinding(graphqlResponse, UpdateResourcePropertyResponse);
    }
    remote isolated function getSupply(int id) returns GetSupplyResponse|graphql:ClientError {
        string query = string `query getSupply($id:Int!) {supply(id:$id) {id asset {id} consumable {id} supplier {id} person {id} order_date delivery_date order_id order_amount}}`;
        map<anydata> variables = {"id": id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetSupplyResponse> check performDataBinding(graphqlResponse, GetSupplyResponse);
    }
    remote isolated function getSupplies() returns GetSuppliesResponse|graphql:ClientError {
        string query = string `query getSupplies {supplies {id asset {id} consumable {id} supplier {id} person {id} order_date delivery_date order_id order_amount}}`;
        map<anydata> variables = {};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetSuppliesResponse> check performDataBinding(graphqlResponse, GetSuppliesResponse);
    }
    remote isolated function addSupply(Supply supply) returns AddSupplyResponse|graphql:ClientError {
        string query = string `mutation addSupply($supply:Supply!) {add_supply(supply:$supply) {id asset {id} consumable {id} supplier {id} person {id} order_date delivery_date order_id order_amount}}`;
        map<anydata> variables = {"supply": supply};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <AddSupplyResponse> check performDataBinding(graphqlResponse, AddSupplyResponse);
    }
    remote isolated function updateSupply(Supply supply) returns UpdateSupplyResponse|graphql:ClientError {
        string query = string `mutation updateSupply($supply:Supply!) {update_supply(supply:$supply) {id asset {id} consumable {id} supplier {id} person {id} order_date delivery_date order_id order_amount}}`;
        map<anydata> variables = {"supply": supply};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <UpdateSupplyResponse> check performDataBinding(graphqlResponse, UpdateSupplyResponse);
    }
    remote isolated function getResourceAllocation(int id) returns GetResourceAllocationResponse|graphql:ClientError {
        string query = string `query getResourceAllocation($id:Int!) {resource_allocation(id:$id) {id requested approved allocated asset {id} consumable {id} organization {id} person {id} quantity start_date end_date}}`;
        map<anydata> variables = {"id": id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetResourceAllocationResponse> check performDataBinding(graphqlResponse, GetResourceAllocationResponse);
    }
    remote isolated function getResourceAllocationByPerson(int id) returns GetResourceAllocationByPersonResponse|graphql:ClientError {
        string query = string `query getResourceAllocationByPerson($id:Int!) {resource_allocation(person_id:$id) {id requested approved allocated asset {id name manufacturer model serial_number registration_number description avinya_type {id}} consumable {id} organization {id} person {id} quantity start_date end_date}}`;
        map<anydata> variables = {"id": id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetResourceAllocationByPersonResponse> check performDataBinding(graphqlResponse, GetResourceAllocationByPersonResponse);
    }
    remote isolated function getResourceAllocations() returns GetResourceAllocationsResponse|graphql:ClientError {
        string query = string `query getResourceAllocations {resource_allocations {id requested approved allocated asset {id} consumable {id} organization {id} person {id} quantity start_date end_date}}`;
        map<anydata> variables = {};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetResourceAllocationsResponse> check performDataBinding(graphqlResponse, GetResourceAllocationsResponse);
    }
    remote isolated function addResourceAllocation(ResourceAllocation resourceallocation) returns AddResourceAllocationResponse|graphql:ClientError {
        string query = string `mutation addResourceAllocation($resourceallocation:ResourceAllocation!) {add_resource_allocation(resourceAllocation:$resourceallocation) {id requested approved allocated asset {id} consumable {id} organization {id} person {id} quantity start_date end_date}}`;
        map<anydata> variables = {"resourceallocation": resourceallocation};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <AddResourceAllocationResponse> check performDataBinding(graphqlResponse, AddResourceAllocationResponse);
    }
    remote isolated function updateResourceAllocation(ResourceAllocation resourceallocation) returns UpdateResourceAllocationResponse|graphql:ClientError {
        string query = string `mutation updateResourceAllocation($resourceallocation:ResourceAllocation!) {update_resource_allocation(resourceAllocation:$resourceallocation) {id requested approved allocated asset {id} consumable {id} organization {id} person {id} quantity start_date end_date}}`;
        map<anydata> variables = {"resourceallocation": resourceallocation};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <UpdateResourceAllocationResponse> check performDataBinding(graphqlResponse, UpdateResourceAllocationResponse);
    }
    remote isolated function getInventory(int id) returns GetInventoryResponse|graphql:ClientError {
        string query = string `query getInventory($id:Int!) {inventory(id:$id) {id asset {id} consumable {id} organization {id} person {id} avinya_type {id active description focus foundation_type global_type level name} avinya_type_id quantity quantity_in quantity_out}}`;
        map<anydata> variables = {"id": id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetInventoryResponse> check performDataBinding(graphqlResponse, GetInventoryResponse);
    }
    remote isolated function getInventories() returns GetInventoriesResponse|graphql:ClientError {
        string query = string `query getInventories {inventories {id asset {id} consumable {id} organization {id} person {id} avinya_type {id active description focus foundation_type global_type level name} avinya_type_id quantity quantity_in quantity_out}}`;
        map<anydata> variables = {};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetInventoriesResponse> check performDataBinding(graphqlResponse, GetInventoriesResponse);
    }
    remote isolated function addInventory(Inventory inventory) returns AddInventoryResponse|graphql:ClientError {
        string query = string `mutation addInventory($inventory:Inventory!) {add_inventory(inventory:$inventory) {id asset {id} consumable {id} organization {id} person {id} avinya_type {id} quantity quantity_in quantity_out}}`;
        map<anydata> variables = {"inventory": inventory};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <AddInventoryResponse> check performDataBinding(graphqlResponse, AddInventoryResponse);
    }
    remote isolated function updateInventory(Inventory inventory) returns UpdateInventoryResponse|graphql:ClientError {
        string query = string `mutation updateInventory($inventory:Inventory!) {update_inventory(inventory:$inventory) {id asset {id} consumable {id} organization {id} person {id} avinya_type {id} quantity quantity_in quantity_out}}`;
        map<anydata> variables = {"inventory": inventory};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <UpdateInventoryResponse> check performDataBinding(graphqlResponse, UpdateInventoryResponse);
    }
    remote isolated function getAssetByAvinyaType(int id) returns GetAssetByAvinyaTypeResponse|graphql:ClientError {
        string query = string `query getAssetByAvinyaType($id:Int!) {asset_by_avinya_type(id:$id) {id name model manufacturer description registration_number serial_number avinya_type_id avinya_type {id}}}`;
        map<anydata> variables = {"id": id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetAssetByAvinyaTypeResponse> check performDataBinding(graphqlResponse, GetAssetByAvinyaTypeResponse);
    }
    remote isolated function getAvinyaTypeByAsset() returns GetAvinyaTypeByAssetResponse|graphql:ClientError {
        string query = string `query getAvinyaTypeByAsset {avinya_types_by_asset {id name global_type foundation_type description focus active level}}`;
        map<anydata> variables = {};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetAvinyaTypeByAssetResponse> check performDataBinding(graphqlResponse, GetAvinyaTypeByAssetResponse);
    }
    remote isolated function getResourceAllocationReport(int organization_id, int avinya_type_id) returns GetResourceAllocationReportResponse|graphql:ClientError {
        string query = string `query getResourceAllocationReport($organization_id:Int!,$avinya_type_id:Int!) {resource_allocations_report(organization_id:$organization_id,avinya_type_id:$avinya_type_id) {id requested approved allocated asset {id name manufacturer model serial_number registration_number description} resource_properties {property value} organization {id description name {name_en}} person {id preferred_name digital_id} quantity start_date end_date}}`;
        map<anydata> variables = {"organization_id": organization_id, "avinya_type_id": avinya_type_id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetResourceAllocationReportResponse> check performDataBinding(graphqlResponse, GetResourceAllocationReportResponse);
    }
    remote isolated function getOrganizationsByAvinyaType(int avinya_type) returns GetOrganizationsByAvinyaTypeResponse|graphql:ClientError {
        string query = string `query getOrganizationsByAvinyaType($avinya_type:Int!) {organizations_by_avinya_type(avinya_type:$avinya_type) {id name {name_en} description}}`;
        map<anydata> variables = {"avinya_type": avinya_type};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetOrganizationsByAvinyaTypeResponse> check performDataBinding(graphqlResponse, GetOrganizationsByAvinyaTypeResponse);
    }
    remote isolated function getAvinyaTypes() returns GetAvinyaTypesResponse|graphql:ClientError {
        string query = string `query getAvinyaTypes {avinya_types {id active name global_type foundation_type focus level description}}`;
        map<anydata> variables = {};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetAvinyaTypesResponse> check performDataBinding(graphqlResponse, GetAvinyaTypesResponse);
    }
    remote isolated function getInventoryDataByOrganization(string date, int organization_id) returns GetInventoryDataByOrganizationResponse|graphql:ClientError {
        string query = string `query getInventoryDataByOrganization($organization_id:Int!,$date:String!) {inventory_data_by_organization(organization_id:$organization_id,date:$date) {id avinya_type_id consumable_id consumable {id name} quantity quantity_in quantity_out prev_quantity resource_property {id property value} created updated}}`;
        map<anydata> variables = {"date": date, "organization_id": organization_id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetInventoryDataByOrganizationResponse> check performDataBinding(graphqlResponse, GetInventoryDataByOrganizationResponse);
    }
    remote isolated function getConsumableWeeklyReport(string from_date, string to_date, int organization_id) returns GetConsumableWeeklyReportResponse|graphql:ClientError {
        string query = string `query getConsumableWeeklyReport($organization_id:Int!,$from_date:String!,$to_date:String!) {consumable_weekly_report(organization_id:$organization_id,from_date:$from_date,to_date:$to_date) {id avinya_type {id global_type name} consumable {id name description manufacturer} prev_quantity quantity_in quantity_out resource_property {id property value} updated}}`;
        map<anydata> variables = {"from_date": from_date, "to_date": to_date, "organization_id": organization_id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetConsumableWeeklyReportResponse> check performDataBinding(graphqlResponse, GetConsumableWeeklyReportResponse);
    }
    remote isolated function getConsumableMonthlyReport(int month, int year, int organization_id) returns GetConsumableMonthlyReportResponse|graphql:ClientError {
        string query = string `query getConsumableMonthlyReport($organization_id:Int!,$year:Int!,$month:Int!) {consumable_monthly_report(organization_id:$organization_id,year:$year,month:$month) {consumable {id name description manufacturer} quantity quantity_in quantity_out resource_property {id property value}}}`;
        map<anydata> variables = {"month": month, "year": year, "organization_id": organization_id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetConsumableMonthlyReportResponse> check performDataBinding(graphqlResponse, GetConsumableMonthlyReportResponse);
    }
}
