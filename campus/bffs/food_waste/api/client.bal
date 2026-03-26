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
    remote isolated function GetFoodItems(string? mealType = ()) returns GetFoodItemsResponse|graphql:ClientError {
        string query = string `query GetFoodItems($mealType:String) {food_items(meal_type:$mealType) {id name cost_per_portion meal_type created updated}}`;
        map<anydata> variables = {"mealType": mealType};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetFoodItemsResponse> check performDataBinding(graphqlResponse, GetFoodItemsResponse);
    }
    remote isolated function AddFoodItem(anydata costPerPortion, string name, string mealType) returns AddFoodItemResponse|graphql:ClientError {
        string query = string `mutation AddFoodItem($name:String!,$costPerPortion:Decimal!,$mealType:String!) {add_food_item(food_item:{name:$name,cost_per_portion:$costPerPortion,meal_type:$mealType}) {id name cost_per_portion meal_type created updated}}`;
        map<anydata> variables = {"costPerPortion": costPerPortion, "name": name, "mealType": mealType};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <AddFoodItemResponse> check performDataBinding(graphqlResponse, AddFoodItemResponse);
    }
    remote isolated function UpdateFoodItem(anydata costPerPortion, string name, string mealType, int id) returns UpdateFoodItemResponse|graphql:ClientError {
        string query = string `mutation UpdateFoodItem($id:Int!,$name:String!,$costPerPortion:Decimal!,$mealType:String!) {update_food_item(food_item:{id:$id,name:$name,cost_per_portion:$costPerPortion,meal_type:$mealType}) {id name cost_per_portion meal_type is_deleted created updated}}`;
        map<anydata> variables = {"costPerPortion": costPerPortion, "name": name, "mealType": mealType, "id": id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <UpdateFoodItemResponse> check performDataBinding(graphqlResponse, UpdateFoodItemResponse);
    }
    remote isolated function GetMealServings(int offset, int 'limit, string? fromDate = (), string? toDate = (), int? id = ()) returns GetMealServingsResponse|graphql:ClientError {
        string query = string `query GetMealServings($id:Int,$fromDate:String,$toDate:String,$limit:Int!,$offset:Int!) {meal_servings(id:$id,fromDate:$fromDate,toDate:$toDate,limit:$limit,offset:$offset) {id serving_date meal_type}}`;
        map<anydata> variables = {"fromDate": fromDate, "offset": offset, "toDate": toDate, "limit": 'limit, "id": id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetMealServingsResponse> check performDataBinding(graphqlResponse, GetMealServingsResponse);
    }
    remote isolated function AddMealServing(int organizationId, int servedCount, string servingDate, string mealType, string? notes = ()) returns AddMealServingResponse|graphql:ClientError {
        string query = string `mutation AddMealServing($servingDate:String!,$mealType:String!,$servedCount:Int!,$organizationId:Int!,$notes:String) {add_meal_serving(meal_serving:{serving_date:$servingDate,meal_type:$mealType,served_count:$servedCount,organization_id:$organizationId,notes:$notes}) {id serving_date meal_type served_count organization_id notes created updated}}`;
        map<anydata> variables = {"organizationId": organizationId, "servedCount": servedCount, "servingDate": servingDate, "notes": notes, "mealType": mealType};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <AddMealServingResponse> check performDataBinding(graphqlResponse, AddMealServingResponse);
    }
    remote isolated function UpdateMealServing(int servedCount, string servingDate, string mealType, int id, string? notes = ()) returns UpdateMealServingResponse|graphql:ClientError {
        string query = string `mutation UpdateMealServing($id:Int!,$servingDate:String!,$mealType:String!,$servedCount:Int!,$notes:String) {update_meal_serving(meal_serving:{id:$id,serving_date:$servingDate,meal_type:$mealType,served_count:$servedCount,notes:$notes}) {id serving_date meal_type served_count organization_id notes created updated}}`;
        map<anydata> variables = {"servedCount": servedCount, "servingDate": servingDate, "notes": notes, "mealType": mealType, "id": id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <UpdateMealServingResponse> check performDataBinding(graphqlResponse, UpdateMealServingResponse);
    }
    remote isolated function AddFoodWaste(int mealServingId, int foodItemId, int wastedPortions) returns AddFoodWasteResponse|graphql:ClientError {
        string query = string `mutation AddFoodWaste($mealServingId:Int!,$foodItemId:Int!,$wastedPortions:Int!) {add_food_waste(food_waste:{meal_serving_id:$mealServingId,food_item_id:$foodItemId,wasted_portions:$wastedPortions}) {id meal_serving_id food_item_id wasted_portions created updated}}`;
        map<anydata> variables = {"mealServingId": mealServingId, "foodItemId": foodItemId, "wastedPortions": wastedPortions};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <AddFoodWasteResponse> check performDataBinding(graphqlResponse, AddFoodWasteResponse);
    }
    remote isolated function GetWasteData(int days) returns GetWasteDataResponse|graphql:ClientError {
        string query = string `query GetWasteData($days:Int!) {daily_waste(days:$days) {date total_waste}}`;
        map<anydata> variables = {"days": days};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetWasteDataResponse> check performDataBinding(graphqlResponse, GetWasteDataResponse);
    }
    remote isolated function GetTopWastedItemsRecentWeek(int 'limit) returns GetTopWastedItemsRecentWeekResponse|graphql:ClientError {
        string query = string `query GetTopWastedItemsRecentWeek($limit:Int!) {top_wasted_items_recent_week(limit:$limit) {food_item_id food_name total_portions total_cost}}`;
        map<anydata> variables = {"limit": 'limit};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetTopWastedItemsRecentWeekResponse> check performDataBinding(graphqlResponse, GetTopWastedItemsRecentWeekResponse);
    }
    remote isolated function GetAnalytics(int? days = ()) returns GetAnalyticsResponse|graphql:ClientError {
        string query = string `query GetAnalytics($days:Int) {getAnalyticsData(days:$days) {average_daily_waste_cost weekly_total_cost}}`;
        map<anydata> variables = {"days": days};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetAnalyticsResponse> check performDataBinding(graphqlResponse, GetAnalyticsResponse);
    }
    remote isolated function DeleteFoodItem(int id) returns DeleteFoodItemResponse|graphql:ClientError {
        string query = string `mutation DeleteFoodItem($id:Int!) {delete_food_item(id:$id)}`;
        map<anydata> variables = {"id": id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <DeleteFoodItemResponse> check performDataBinding(graphqlResponse, DeleteFoodItemResponse);
    }
    remote isolated function DeleteMealServing(int id) returns DeleteMealServingResponse|graphql:ClientError {
        string query = string `mutation DeleteMealServing($id:Int!) {delete_meal_serving(id:$id)}`;
        map<anydata> variables = {"id": id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <DeleteMealServingResponse> check performDataBinding(graphqlResponse, DeleteMealServingResponse);
    }
    remote isolated function DeleteFoodWaste(int id) returns DeleteFoodWasteResponse|graphql:ClientError {
        string query = string `mutation DeleteFoodWaste($id:Int!) {delete_food_waste(id:$id)}`;
        map<anydata> variables = {"id": id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <DeleteFoodWasteResponse> check performDataBinding(graphqlResponse, DeleteFoodWasteResponse);
    }
}
