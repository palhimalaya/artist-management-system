require 'pg'
require_relative 'config'

def db_connection
  @db_connection ||= begin
    puts '🔌 Connecting to DB...'
    conn = PG.connect(DB_CONFIG)
    puts '✅ DB connected'
    conn
  end
end
