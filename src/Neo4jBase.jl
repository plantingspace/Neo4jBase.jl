module Neo4jBase

export Connection, commit, isavailable, root_discovery

using HTTP, JSON3, StructTypes, Base64

endpoint(host::String, port::Int; use_https::Bool = false) =
  string("http", use_https ? "s" : "", "://", host, ":", port)
endpoint(host::String, port::Int, db::String; use_https::Bool = false) =
  string(endpoint(host, port; use_https), "/db/", db, "/tx")

headers(username::String, password::String) = Dict(
  "Accept" => "application/json; charset=UTF-8",
  "Content-Type" => "application/json",
  "Authorization" => "Basic $(base64encode(string(username, ":", password)))"
)

struct Connection
  endpoint::String
  headers::Dict{String, String}
  config::NamedTuple
end
Connection(;
  host::String="localhost",
  port::Int=7474,
  db::String="neo4j",
  username::String="neo4j",
  password::String="neo4j",
  use_https::Bool = false,
  config...
  ) =
  Connection(endpoint(host, port, db; use_https), headers(username, password), NamedTuple(config))

parse(response::HTTP.Messages.Response)::JSON3.Object = JSON3.read(response.body)

root_discovery(host::String, port::Int; config...)::Union{JSON3.Object, Nothing} =
  try
    result = HTTP.get(endpoint(host, port); config...) |> parse
  catch e
    @debug "Could not establish a Neo4j connection, host returned the following $(sprint(showerror, e))"
  end

"""
Check whether `conn` points to an available server with a default timeout of 5 seconds.

A custom timeout can be provided (in seconds) and will be disabled if set to zero.
"""
function isavailable(conn::Connection; timeout::Integer = 5)
  # just keep method://host:port
  endpoint = conn.endpoint[1:first(findfirst("/db", conn.endpoint))]
  try
    result = HTTP.get(endpoint, conn.headers; conn.config..., connect_timeout = timeout) |> parse
    true
  catch e
    if !isa(e, HTTP.ConnectionPool.ConnectTimeout)
      @debug "Trying to connect to a database at $endpoint returned an error: $(sprint(showerror, e))"
    end
    return false
  end
end

struct Statement
  statement::String
  parameters::Dict
end
Statement(statement::String) = Statement(statement, Dict())
StructTypes.StructType(::Type{Statement}) = StructTypes.Struct()

struct Statements
  statements::Vector{Statement}
end
Statements(sts::String...) = Statements(collect(map(Statement, sts)))
StructTypes.StructType(::Type{Statements}) = StructTypes.Struct()

commit(conn::Connection, sts::Statements)::Union{JSON3.Array, Nothing} =
  try
    result = HTTP.post(
      string(conn.endpoint, "/commit"),
      conn.headers,
      JSON3.write(sts); conn.config...) |> parse

    if !isempty(result[:errors])
      error(result[:errors])
    else
      return result[:results]
    end
  catch e
    @error "The Neo4j database host returned the following error" exception = first(Base.catch_stack())
  end

commit(conn::Connection, st::String)::Union{JSON3.Array, Nothing} =
  commit(conn, Statements(st))

end
