# Neo4jBase.jl

Julia library for interacting with [Neo4j](https://neo4j.com/) databases using the [HTTP API](https://neo4j.com/docs/http-api/current/actions/#http-api-actions).

Supports only basic HTTP methods for now, but is functional. Written since the two other Julia Neo4j packages do not work [Neo4jBolt.jl](https://github.com/virtualgraham/Neo4jBolt.jl/issues) and [Neo4j.jl](https://github.com/glesica/Neo4j.jl).

More functionality and documentation may come later, PRs welcome.

# API Referece
### `Connection(;host::String, port::Int, db::String, username::String, password::String)`
Defines the Neo4j database connection. If keyword arguments are not specified, connection to default local database is created. Returns `nothing` if there was an issue connecting.

### `commit(conn::Connection, query::String)`
Commit the Cypher query to the database and get the results or `nothing` if an error occured.

### `Neo4jBase.root_discovery(host::String, port::Int)`
Fetches a list of other Neo4j URIs, as well as version information of the server.
