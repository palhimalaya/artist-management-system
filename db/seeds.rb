require 'bcrypt'
require 'dotenv/load'
require_relative 'connection'

db = db_checkout

def seed_user(db, first_name, email, password, role)
  existing = db.exec_params('SELECT 1 FROM users WHERE email = $1', [email])
  if existing.any?
    puts "User #{email} already exists, skipping."
    return
  end

  hashed_password = BCrypt::Password.create(password)
  db.exec_params(
    'INSERT INTO users (first_name, email, password, role) VALUES ($1, $2, $3, $4)',
    [first_name, email, hashed_password, role]
  )
  puts "Seeded: #{email} (#{role})"
end

seed_user(db, 'Admin', 'admin@artistms.com', 'password', 'super_admin')

seed_user(db, 'John Manager', 'john@artistms.com', 'password', 'artist_manager')
seed_user(db, 'Jane Manager', 'jane@artistms.com', 'password', 'artist_manager')
seed_user(db, 'Bob Artist', 'bob@artistms.com', 'password', 'artist')
seed_user(db, 'Alice Artist', 'alice@artistms.com', 'password', 'artist')
seed_user(db, 'Charlie Artist', 'charlie@artistms.com', 'password', 'artist')
seed_user(db, 'Diana Artist', 'diana@artistms.com', 'password', 'artist')
seed_user(db, 'Eve Artist', 'eve@artistms.com', 'password', 'artist')
seed_user(db, 'Frank Artist', 'frank@artistms.com', 'password', 'artist')
seed_user(db, 'Grace Artist', 'grace@artistms.com', 'password', 'artist')
seed_user(db, 'Henry Artist', 'henry@artistms.com', 'password', 'artist')
seed_user(db, 'Ivy Artist', 'ivy@artistms.com', 'password', 'artist')

puts 'Seed complete.'
