require 'bcrypt'
require 'dotenv/load'
require_relative 'connection'

db = db_connection

existing = db.exec("SELECT 1 FROM users WHERE email = 'admin@artistms.com'")
if existing.any?
  puts 'Admin user already exists, skipping.'
else
  password = BCrypt::Password.create('password')
  db.exec_params(
    "INSERT INTO users (first_name, email, password, role)
     VALUES ($1, $2, $3, $4)",
    ['Admin', 'admin@artistms.com', password, 'super_admin']
  )
  puts 'Admin user seeded successfully.'
end
