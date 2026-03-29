require 'pg'
require 'connection_pool'
require_relative 'config'

DB_POOL = ConnectionPool.new(size: 5, timeout: 5) do
  conn = PG.connect(DB_CONFIG)
  conn.type_map_for_results = PG::BasicTypeMapForResults.new(conn)
  conn
end

def db_connection(&)
  DB_POOL.with(&)
end

# For one-off scripts (seeds, migrations, console) that need a long-lived connection.
# Web request code MUST use db_connection { |db| ... } instead.
def db_checkout
  DB_POOL.checkout
end
