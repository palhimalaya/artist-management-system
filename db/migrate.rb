require 'dotenv/load'
require_relative 'connection'

db = db_checkout

# Create tracking table
db.exec <<-SQL
  CREATE TABLE IF NOT EXISTS schema_migrations (
    version VARCHAR(50) PRIMARY KEY
  );
SQL

# Get already run migrations
result = db.exec('SELECT version FROM schema_migrations')
applied = result.map { |r| r['version'] }

# Read migration files
migration_files = Dir['db/migrations/*.rb'].sort

migration_files.each do |file|
  version = File.basename(file, '.rb')

  next if applied.include?(version)

  puts "Running #{version}..."

  load file
  up(db)

  db.exec('INSERT INTO schema_migrations (version) VALUES ($1)', [version])

  puts "✅ Done #{version}"
end

puts '🎉 All migrations complete!'
