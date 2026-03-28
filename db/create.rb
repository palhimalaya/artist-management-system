require 'pg'
require_relative 'config'

begin
  conn = PG.connect(DEFAULT_DB_CONFIG)

  conn.exec("CREATE DATABASE #{DB_CONFIG['dbname']}")
  puts '✅ Database created!'
rescue PG::DuplicateDatabase
  puts '⚠️ Database already exists.'
ensure
  conn&.close
end
