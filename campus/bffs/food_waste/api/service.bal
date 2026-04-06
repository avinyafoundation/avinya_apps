import ballerina/http;
import ballerina/log;

public function initClientConfig() returns ConnectionConfig {
    ConnectionConfig _clientConig = {};
    if (GLOBAL_DATA_USE_AUTH) {
        _clientConig.oauth2ClientCredentialsGrantConfig = {
            tokenUrl: CHOREO_TOKEN_URL,
            clientId: GLOBAL_DATA_CLIENT_ID,
            clientSecret: GLOBAL_DATA_CLIENT_SECRET
        };
    } else {
        _clientConig = {};
    }
    // log:printDebug("debug log");
    // log:printError("error log");
    // log:printInfo("info log");
    // log:printWarn("warn log");
    // log:printInfo("CHOREO_TOKEN_URL: " + CHOREO_TOKEN_URL);
    // log:printInfo("GLOBAL_DATA_CLIENT_ID: " + GLOBAL_DATA_CLIENT_ID);
    // log:printInfo("GLOBAL_DATA_CLIENT_SECRET: " + GLOBAL_DATA_CLIENT_SECRET);
    return _clientConig;
}

final GraphqlClient globalDataClient = check new (GLOBAL_DATA_API_URL,
    config = initClientConfig()
);

@http:ServiceConfig {
    cors: {
        allowOrigins: ["*"]
    }
}

service / on new http:Listener(9098) {
    private final GraphqlClient graphqlClient;

    function init() returns error? {
        self.graphqlClient = globalDataClient;
    }

    // Food Items Endpoints
    resource function get food_items(string? meal_type) returns GetFoodItemsResponse|error {
        do {
            GetFoodItemsResponse response = check self.graphqlClient->GetFoodItems(meal_type);
            return response;
        } on fail var e {
            log:printError("Error fetching food items", e);
            return e;
        }
    }

    resource function post food_items(FoodItemInput foodItem) returns AddFoodItemResponse|error {
        do {
            AddFoodItemResponse response = check self.graphqlClient->AddFoodItem(foodItem.cost_per_portion, foodItem.name, foodItem.meal_type);
            return response;
        } on fail var e {
            log:printError("Error adding food item", e);
            return e;
        }
    }

    resource function put food_items/[int id](FoodItemUpdateInput foodItem) returns UpdateFoodItemResponse|error {
        do {
            UpdateFoodItemResponse response = check self.graphqlClient->UpdateFoodItem(foodItem.cost_per_portion, foodItem.name, foodItem.meal_type, id);
            return response;
        } on fail var e {
            log:printError("Error updating food item", e);
            return e;
        }
    }

    // Meal Servings Endpoints
    resource function get meal_servings/organizations/[int organization_id](int offset, int 'limit, string? from_date = (), string? to_date = (), int? id = ()) returns GetMealServingsResponse|error {
        do {
            GetMealServingsResponse response = check self.graphqlClient->GetMealServings(organization_id, from_date, offset, to_date, 'limit, id);
            return response;
        } on fail var e {
            log:printError("Error fetching meal servings", e);
            return e;
        }
    }

    resource function post meal_servings(MealServingInput mealServing) returns AddMealServingResponse|error {
        do {
            AddMealServingResponse response = check self.graphqlClient->AddMealServing(mealServing.organization_id, mealServing.served_count, mealServing.serving_date, mealServing.meal_type, mealServing.notes, mealServing.food_wastes);
            return response;
        } on fail var e {
            log:printError("Error adding meal serving", e);
            return e;
        }
    }

    resource function put meal_servings/[int id](MealServingUpdateInput mealServing) returns UpdateMealServingResponse|error {
        do {
            UpdateMealServingResponse response = check self.graphqlClient->UpdateMealServing(mealServing.served_count, mealServing.serving_date, mealServing.meal_type, id, mealServing.notes, mealServing.food_wastes);
            return response;
        } on fail var e {
            log:printError("Error updating meal serving", e);
            return e;
        }
    }

    // Analytics Endpoints
    resource function get analytics/organizations/[int organization_id]/waste(int days) returns GetWasteDataResponse|error {
        do {
            GetWasteDataResponse response = check self.graphqlClient->GetWasteData(organization_id, days);
            return response;
        } on fail var e {
            log:printError("Error fetching waste data", e);
            return e;
        }
    }

    resource function get analytics/organizations/[int organization_id]/top_wasted(int 'limit) returns GetTopWastedItemsResponse|error {
        do {
            GetTopWastedItemsResponse response = check self.graphqlClient->GetTopWastedItems(organization_id, 'limit);
            return response;
        } on fail var e {
            log:printError("Error fetching top wasted items", e);
            return e;
        }
    }

    resource function get analytics/organizations/[int organization_id]/summary(int? days = ()) returns GetAnalyticsResponse|error {
        do {
            GetAnalyticsResponse response = check self.graphqlClient->GetAnalytics(organization_id, days);
            return response;
        } on fail var e {
            log:printError("Error fetching analytics", e);
            return e;
        }
    }

    // Delete Endpoints
    resource function delete food_items/[int id]() returns json|error {
        json|error delete_result = self.graphqlClient->DeleteFoodItem(id);
        return delete_result;
    }

    resource function delete meal_servings/[int id]() returns json|error {
        json|error delete_result = self.graphqlClient->DeleteMealServing(id);
        return delete_result;
    }   
}
