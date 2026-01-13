import ballerina/graphql;

public isolated client class GraphqlClient {
    final graphql:Client graphqlClient;
    public isolated function init(string serviceUrl, ConnectionConfig config = {}) returns graphql:ClientError? {
        graphql:ClientConfiguration graphqlClientConfig = {auth: config.oauth2ClientCredentialsGrantConfig,timeout: config.timeout, forwarded: config.forwarded, poolConfig: config.poolConfig, compression: config.compression, circuitBreaker: config.circuitBreaker, retryConfig: config.retryConfig, validation: config.validation};
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
    
    remote isolated function saveOrganizationLocation(int organizationId, OrganizationLocation organizationLocation) returns SaveOrganizationLocationResponse|graphql:ClientError {
        string query = string `mutation saveOrganizationLocation($organizationId:Int!,$organizationLocation:OrganizationLocation!) {saveOrganizationLocation(organizationId:$organizationId,organizationLocation:$organizationLocation) {id organization_id location_name description}}`;
        map<anydata> variables = {"organizationId": organizationId, "organizationLocation": organizationLocation};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <SaveOrganizationLocationResponse> check performDataBinding(graphqlResponse, SaveOrganizationLocationResponse);
    }
    remote isolated function getLocationsByOrganization(int organizationId) returns GetLocationsByOrganizationResponse|graphql:ClientError {
        string query = string `query getLocationsByOrganization($organizationId:Int!) {locationsByOrganization(organizationId:$organizationId) {id organization_id location_name description}}`;
        map<anydata> variables = {"organizationId": organizationId};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetLocationsByOrganizationResponse> check performDataBinding(graphqlResponse, GetLocationsByOrganizationResponse);
    }
    remote isolated function getEmployeesByOrganization(int organization_id, int? avinya_type_id = ()) returns GetEmployeesByOrganizationResponse|graphql:ClientError {
        string query = string `query getEmployeesByOrganization($organization_id:Int!,$avinya_type_id:Int) {persons(organization_id:$organization_id,avinya_type_id:$avinya_type_id) {id preferred_name}}`;
        map<anydata> variables = {"organization_id": organization_id, "avinya_type_id": avinya_type_id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetEmployeesByOrganizationResponse> check performDataBinding(graphqlResponse, GetEmployeesByOrganizationResponse);
    }
    remote isolated function createMaintenanceTask(int organizationId, MaintenanceTask maintenanceTask, MaterialCost[]? materialCosts = (), MaintenanceFinance? finance = ()) returns CreateMaintenanceTaskResponse|graphql:ClientError {
        string query = string `mutation createMaintenanceTask($organizationId:Int!,$maintenanceTask:MaintenanceTask!,$finance:MaintenanceFinance,$materialCosts:[MaterialCost!]) {createMaintenanceTask(organizationId:$organizationId,maintenanceTask:$maintenanceTask,finance:$finance,materialCosts:$materialCosts) {id}}`;
        map<anydata> variables = {"organizationId": organizationId, "maintenanceTask": maintenanceTask, "materialCosts": materialCosts, "finance": finance};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <CreateMaintenanceTaskResponse>check performDataBinding(graphqlResponse, CreateMaintenanceTaskResponse);
    }

    remote isolated function MaintenanceTasks(int organizationId, int offset, int 'limit, string? fromDate = (), string? taskType = (), string? toDate = (), string? financialStatus = (), int[]? personId = (), int? location = (), string? title = (), string? taskStatus = ()) returns MaintenanceTasksResponse|graphql:ClientError {
        string query = string `query MaintenanceTasks($organizationId:Int!,$personId:[Int!],$fromDate:String,$toDate:String,$taskStatus:String,$financialStatus:String,$taskType:String,$location:Int,$title:String,$limit:Int!,$offset:Int!) {maintenanceTasks(organizationId:$organizationId,personId:$personId,fromDate:$fromDate,toDate:$toDate,taskStatus:$taskStatus,financialStatus:$financialStatus,taskType:$taskType,title:$title,location:$location,limit:$limit,offset:$offset) {id start_time end_time overall_task_status task {id title description task_type frequency exception_deadline location {id location_name}} activity_participants {id participant_task_status person {id preferred_name}} finance {id estimated_cost labour_cost material_costs {id item quantity unit unit_cost} status rejection_reason reviewed_by reviewed_date}}}`;
        map<anydata> variables = {"organizationId": organizationId, "fromDate": fromDate, "taskType": taskType, "offset": offset, "toDate": toDate, "financialStatus": financialStatus, "limit": 'limit, "personId": personId, "location": location, "title": title, "taskStatus": taskStatus};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <MaintenanceTasksResponse> check performDataBinding(graphqlResponse, MaintenanceTasksResponse);
    }
    remote isolated function GetOverdueMaintenanceTasks(int organizationId) returns GetOverdueMaintenanceTasksResponse|graphql:ClientError {
        string query = string `query GetOverdueMaintenanceTasks($organizationId:Int!) {overdueMaintenanceTasks(organizationId:$organizationId) {id task_id start_time end_time overall_task_status overdue_days task {id title description task_type frequency location {id location_name}} activity_participants {id participant_task_status person {id preferred_name}}}}`;
        map<anydata> variables = {"organizationId": organizationId};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetOverdueMaintenanceTasksResponse> check performDataBinding(graphqlResponse, GetOverdueMaintenanceTasksResponse);
    }

    remote isolated function SoftDeactivateMaintenanceTask(string modifiedBy, int taskId) returns SoftDeactivateMaintenanceTaskResponse|graphql:ClientError {
        string query = string `mutation SoftDeactivateMaintenanceTask($taskId:Int!,$modifiedBy:String!) {softDeactivateMaintenanceTask(taskId:$taskId,modifiedBy:$modifiedBy) {id modified_by}}`;
        map<anydata> variables = {"modifiedBy": modifiedBy, "taskId": taskId};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <SoftDeactivateMaintenanceTaskResponse> check performDataBinding(graphqlResponse, SoftDeactivateMaintenanceTaskResponse);
    }
    remote isolated function UpdateMaintenanceFinance(int financeId, MaintenanceFinance maintenanceFinance) returns UpdateMaintenanceFinanceResponse|graphql:ClientError {
        string query = string `mutation UpdateMaintenanceFinance($financeId:Int!,$maintenanceFinance:MaintenanceFinance!) {updateMaintenanceFinance(financeId:$financeId,maintenanceFinance:$maintenanceFinance) {status rejection_reason reviewed_by}}`;
        map<anydata> variables = {"financeId": financeId, "maintenanceFinance": maintenanceFinance};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <UpdateMaintenanceFinanceResponse> check performDataBinding(graphqlResponse, UpdateMaintenanceFinanceResponse);
    }
    remote isolated function GetMonthlyMaintenanceReport(int organizationId, int month, int year) returns GetMonthlyMaintenanceReportResponse|graphql:ClientError {
        string query = string `query GetMonthlyMaintenanceReport($organizationId:Int!,$year:Int!,$month:Int!) {monthlyMaintenanceReport(organizationId:$organizationId,year:$year,month:$month) {totalTasks completedTasks inProgressTasks pendingTasks totalCosts totalUpcomingTasks nextMonthlyEstimatedCost}}`;
        map<anydata> variables = {"organizationId": organizationId, "month": month, "year": year};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetMonthlyMaintenanceReportResponse> check performDataBinding(graphqlResponse, GetMonthlyMaintenanceReportResponse);
    }
    remote isolated function MaintenanceTasksByStatus(int organizationId, int month, int offset, int year, int 'limit, string? overallTaskStatus = ()) returns MaintenanceTasksByStatusResponse|graphql:ClientError {
        string query = string `query MaintenanceTasksByStatus($organizationId:Int!,$month:Int!,$year:Int!,$overallTaskStatus:String,$limit:Int!,$offset:Int!) {maintenanceTasksByMonthYearStatus(organizationId:$organizationId,month:$month,year:$year,overallTaskStatus:$overallTaskStatus,limit:$limit,offset:$offset) {id start_time end_time overall_task_status task {id title description task_type frequency exception_deadline location {id location_name}} activity_participants {id participant_task_status person {id preferred_name}}}}`;
        map<anydata> variables = {"organizationId": organizationId, "overallTaskStatus": overallTaskStatus, "month": month, "offset": offset, "year": year, "limit": 'limit};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <MaintenanceTasksByStatusResponse> check performDataBinding(graphqlResponse, MaintenanceTasksByStatusResponse);
    }
    
}
