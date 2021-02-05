# Neo4jBase.jl

Julia library for interacting with [Neo4j](https://neo4j.com/) databases using the [HTTP API](https://neo4j.com/docs/http-api/current/actions/#http-api-actions).

Supports only basic HTTP methods for now, but is functional. Written since the two other Julia Neo4j packages do not work [Neo4jBolt.jl](https://github.com/virtualgraham/Neo4jBolt.jl/issues) and [Neo4j.jl](https://github.com/glesica/Neo4j.jl).

More functionality and documentation may come later, PRs welcome.

# API Referece
### `Connection(;host::String, port::Int, db::String, username::String, password::String)`
Defines the Neo4j database connection.

### `commit(conn::Connection, st::String)`
Commit the changes to the database, where `st` indicates the `Cypher Query`.

### `Neo4jBase.root_discovery(host::String, port::Int)`
Fetches a list of other URIs, as well as version information of the server.
