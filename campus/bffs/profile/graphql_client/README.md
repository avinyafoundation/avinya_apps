Fetch shema in json format and save to shema.json file 
(use full_schema_query.graphql)

If not already done, install:
https://github.com/potatosalad/graphql-introspection-json-to-sdl

Run:
graphql-introspection-json-to-sdl schema.json > schema.graphql

Copy queries and mutatons to relavant files pointed by graphql.config.yaml

Generage Ballerina client:
bal graphql -i graphql.config.yaml -o graphql_client_cg_src

copy bal files within graphql_client_cg_src to Ballerina REST api project folder
