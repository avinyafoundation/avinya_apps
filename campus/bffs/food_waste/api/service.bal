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

service / on new http:Listener(9099) {
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
    resource function get meal_servings(int offset, int 'limit, string? fromDate, string? toDate, int? id) returns GetMealServingsResponse|error {
        do {
            GetMealServingsResponse response = check self.graphqlClient->GetMealServings(offset, 'limit, fromDate, toDate, id);
            return response;
        } on fail var e {
            log:printError("Error fetching meal servings", e);
            return e;
        }
    }
}
