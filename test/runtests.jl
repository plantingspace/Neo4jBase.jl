using Test
using Neo4jBase
using Logging

@testset "db not available" begin
  conn = Connection()
  @test !isavailable(conn)
  @test_logs min_level=Logging.Info isavailable(conn)
  @test_logs (:debug,) min_level=Logging.Debug isavailable(conn)
end
