import ballerina/os;

// Path the global data serves GraphQL on, appended to an injected base address.
configurable string GLOBAL_DATA_PATH = "/graphql";

// Environment variable an orchestrator uses to inject the global data address.
// OpenChoreo sets this from the workload's `dependencies.endpoints` binding.
configurable string GLOBAL_DATA_URL_ENV = "GLOBAL_DATA_URL";


// Resolves the global data url, preferring an address injected by the platform.
//
// OpenChoreo binds a dependency's resolved address into an environment
// variable, and that address carries no path — so the configured `globalDataPath`
// is appended unless the injected value already ends with it.
function resolveGlobalDataUrl() returns string {
    string injected = os:getEnv(GLOBAL_DATA_URL_ENV).trim();
    if injected.length() == 0 {
        return GLOBAL_DATA_API_URL;
    }
    string base = injected.endsWith("/") ? injected.substring(0, injected.length() - 1) : injected;
    return base.endsWith(GLOBAL_DATA_PATH) ? base : base + GLOBAL_DATA_PATH;
}
