module Neo4jBase

export Connection, commit

using HTTP, JSON3, StructTypes, Base64

endpoint(host::String, port::Int) =
  string("http://", host, ":", port)
endpoint(host::String, port::Int, db::String) =
  string(endpoint(host, port), "/db/", db, "/tx")

headers(username::String, password::String) = Dict(
  "Accept" => "application/json; charset=UTF-8",
  "Content-Type" => "application/json",
  "Authorization" => "Basic $(base64encode(string(username, ":", password)))"
)

struct Connection
  endpoint::String
  headers::Dict{String, String}
end
Connection(;
  host::String="localhost",
  port::Int=7474,
  db::String="neo4j",
  username::String="neo4j",
  password::String="neo4j"
  ) =
  Connection(endpoint(host, port, db), headers(username, password))

parse(response::HTTP.Messages.Response)::JSON3.Object = JSON3.read(response.body)

root_discovery(host::String, port::Int)::Union{JSON3.Object, Nothing} =
  try
    result = endpoint(host, port) |>
     HTTP.get |> parse
  catch e
    @error "Couldn not establish a Neo4j connection, host returned the following 
            $(sprint(showerror, e))"
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

commit(conn::Connection, sts::Statements)::Union{JSON3.Object, Nothing, String} =
  try  
    result =   HTTP.post(
      string(conn.endpoint, "/commit"),
      conn.headers,
      JSON3.write(sts)) |> parse 
  
    if !isempty(result[:errors])
      error(result[:errors])
    else
      result
    end
  catch
    @error "Host returned the following error,
            $(sprint(showerror, e))"
  end

commit(conn::Connection, st::String)::JSON3.Object =
  commit(conn, Statements(st))

end
