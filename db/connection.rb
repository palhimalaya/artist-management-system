require 'pg'
require_relative 'config'

def db_connection
  @db_connection ||= PG.connect(DB_CONFIG)
end
