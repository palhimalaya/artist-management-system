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

def fetch_user_id(db, email)
  result = db.exec_params('SELECT id FROM users WHERE email = $1', [email])
  result.any? ? result.first['id'].to_i : nil
end

def seed_artist(db, name:, dob:, gender:, address:, first_release_year:, no_of_albums_released:, user_email:, created_by_email:)
  existing = db.exec_params('SELECT 1 FROM artists WHERE name = $1', [name])
  if existing.any?
    puts "Artist #{name} already exists, skipping."
    return fetch_artist_id(db, name)
  end

  user_id = user_email ? fetch_user_id(db, user_email) : nil

  if user_id
    linked = db.exec_params('SELECT 1 FROM artists WHERE user_id = $1', [user_id])
    if linked.any?
      puts "User #{user_email} already linked to an artist, skipping."
      return nil
    end
  end

  created_by = fetch_user_id(db, created_by_email)

  db.exec_params(
    'INSERT INTO artists (name, dob, gender, address, first_release_year, no_of_albums_released, user_id, created_by) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)',
    [name, dob, gender, address, first_release_year, no_of_albums_released, user_id, created_by]
  )
  puts "Seeded artist: #{name}"
  fetch_artist_id(db, name)
end

def fetch_artist_id(db, name)
  result = db.exec_params('SELECT id FROM artists WHERE name = $1', [name])
  result.any? ? result.first['id'].to_i : nil
end

def seed_song(db, artist_id:, title:, album_name:, genre:, created_by_email:)
  existing = db.exec_params('SELECT 1 FROM songs WHERE artist_id = $1 AND title = $2', [artist_id, title])
  if existing.any?
    puts "Song #{title} already exists, skipping."
    return
  end

  created_by = fetch_user_id(db, created_by_email)

  db.exec_params(
    'INSERT INTO songs (artist_id, title, album_name, genre, created_by) VALUES ($1, $2, $3, $4, $5)',
    [artist_id, title, album_name, genre, created_by]
  )
  puts "Seeded song: #{title}"
end

# ── Users ──

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

# ── Artists (linked to manager who created them, some linked to artist-role users) ──

bob_id   = seed_artist(db, name: 'Bob Melody',       dob: '1990-03-15', gender: 'Male',   address: '123 Music Lane, Nashville',        first_release_year: 2012, no_of_albums_released: 5, user_email: 'bob@artistms.com',     created_by_email: 'john@artistms.com')
alice_id = seed_artist(db, name: 'Alice Harmony',    dob: '1988-07-22', gender: 'Female', address: '456 Melody Ave, Los Angeles',      first_release_year: 2010, no_of_albums_released: 7, user_email: 'alice@artistms.com',   created_by_email: 'john@artistms.com')
charlie_id = seed_artist(db, name: 'Charlie Beats',  dob: '1995-01-10', gender: 'Male',   address: '789 Rhythm St, New York',          first_release_year: 2018, no_of_albums_released: 2, user_email: 'charlie@artistms.com', created_by_email: 'jane@artistms.com')
diana_id = seed_artist(db, name: 'Diana Vox',        dob: '1992-11-30', gender: 'Female', address: '321 Sound Blvd, Chicago',          first_release_year: 2015, no_of_albums_released: 4, user_email: 'diana@artistms.com',   created_by_email: 'jane@artistms.com')
eve_id = seed_artist(db, name: 'Eve Nova',           dob: '1997-05-18', gender: 'Female', address: '654 Tune Rd, Austin',              first_release_year: 2020, no_of_albums_released: 1, user_email: 'eve@artistms.com',     created_by_email: 'john@artistms.com')
frank_id = seed_artist(db, name: 'Frank Groove',     dob: '1985-09-05', gender: 'Male',   address: '987 Bass St, Seattle',             first_release_year: 2008, no_of_albums_released: 10, user_email: 'frank@artistms.com',  created_by_email: 'john@artistms.com')
grace_id = seed_artist(db, name: 'Grace Note',       dob: '1993-04-12', gender: 'Female', address: '159 Harmony Dr, Portland',         first_release_year: 2016, no_of_albums_released: 3, user_email: 'grace@artistms.com',   created_by_email: 'jane@artistms.com')
henry_id = seed_artist(db, name: 'Henry Chord',      dob: '1991-12-25', gender: 'Male',   address: '753 Tempo Ln, Denver',             first_release_year: 2014, no_of_albums_released: 6, user_email: 'henry@artistms.com',   created_by_email: 'jane@artistms.com')

# Unlinked artists (no user account)
seed_artist(db, name: 'The Wanderers',    dob: nil, gender: nil, address: nil, first_release_year: 2019, no_of_albums_released: 2, user_email: nil,                 created_by_email: 'john@artistms.com')
seed_artist(db, name: 'Silver Strings',   dob: nil, gender: nil, address: nil, first_release_year: 2021, no_of_albums_released: 1, user_email: nil,                 created_by_email: 'jane@artistms.com')

# ── Songs ──

if bob_id
  seed_song(db, artist_id: bob_id, title: 'Sunrise Highway',    album_name: 'Open Road',       genre: 'Country',   created_by_email: 'bob@artistms.com')
  seed_song(db, artist_id: bob_id, title: 'Whiskey Nights',     album_name: 'Open Road',       genre: 'Country',   created_by_email: 'bob@artistms.com')
  seed_song(db, artist_id: bob_id, title: 'Back Porch Song',    album_name: 'Southern Soul',   genre: 'Folk',      created_by_email: 'bob@artistms.com')
  seed_song(db, artist_id: bob_id, title: 'Dusty Trails',       album_name: 'Southern Soul',   genre: 'Country',   created_by_email: 'bob@artistms.com')
end

if alice_id
  seed_song(db, artist_id: alice_id, title: 'Electric Dreams',  album_name: 'Neon Lights',     genre: 'Pop',       created_by_email: 'alice@artistms.com')
  seed_song(db, artist_id: alice_id, title: 'City Glow',        album_name: 'Neon Lights',     genre: 'Pop',       created_by_email: 'alice@artistms.com')
  seed_song(db, artist_id: alice_id, title: 'Velvet Sky',       album_name: 'Midnight Bloom',  genre: 'R&B',       created_by_email: 'alice@artistms.com')
  seed_song(db, artist_id: alice_id, title: 'Ocean Pulse',      album_name: 'Midnight Bloom',  genre: 'R&B',       created_by_email: 'alice@artistms.com')
  seed_song(db, artist_id: alice_id, title: 'Golden Hour',      album_name: 'Midnight Bloom',  genre: 'Pop',       created_by_email: 'alice@artistms.com')
end

if charlie_id
  seed_song(db, artist_id: charlie_id, title: 'Bass Drop',      album_name: 'Frequency',       genre: 'Electronic', created_by_email: 'charlie@artistms.com')
  seed_song(db, artist_id: charlie_id, title: 'Static Wave',    album_name: 'Frequency',       genre: 'Electronic', created_by_email: 'charlie@artistms.com')
  seed_song(db, artist_id: charlie_id, title: 'Neon Pulse',     album_name: 'Frequency',       genre: 'Hip-Hop',  created_by_email: 'charlie@artistms.com')
end

if diana_id
  seed_song(db, artist_id: diana_id, title: 'Silk & Honey',     album_name: 'Voices Carry',    genre: 'Soul',      created_by_email: 'diana@artistms.com')
  seed_song(db, artist_id: diana_id, title: 'Echoes',           album_name: 'Voices Carry',    genre: 'Soul',      created_by_email: 'diana@artistms.com')
  seed_song(db, artist_id: diana_id, title: 'Paper Wings',      album_name: 'Unbound',         genre: 'Indie',     created_by_email: 'diana@artistms.com')
end

if eve_id
  seed_song(db, artist_id: eve_id, title: 'First Light',        album_name: 'Genesis',         genre: 'Indie',     created_by_email: 'eve@artistms.com')
  seed_song(db, artist_id: eve_id, title: 'Stardust',           album_name: 'Genesis',         genre: 'Indie',     created_by_email: 'eve@artistms.com')
end

if frank_id
  seed_song(db, artist_id: frank_id, title: 'Iron Bar Blues',   album_name: 'Heavy Hand',      genre: 'Blues',     created_by_email: 'frank@artistms.com')
  seed_song(db, artist_id: frank_id, title: 'Gravel Road',      album_name: 'Heavy Hand',      genre: 'Rock',      created_by_email: 'frank@artistms.com')
  seed_song(db, artist_id: frank_id, title: 'Midnight Train',   album_name: 'Side B',          genre: 'Blues',     created_by_email: 'frank@artistms.com')
  seed_song(db, artist_id: frank_id, title: 'Copper Kettle',    album_name: 'Side B',          genre: 'Folk',      created_by_email: 'frank@artistms.com')
end

if grace_id
  seed_song(db, artist_id: grace_id, title: 'Petal Dance',      album_name: 'In Bloom',        genre: 'Classical', created_by_email: 'grace@artistms.com')
  seed_song(db, artist_id: grace_id, title: 'Moonlit Sonata',   album_name: 'In Bloom',        genre: 'Classical', created_by_email: 'grace@artistms.com')
end

if henry_id
  seed_song(db, artist_id: henry_id, title: 'Six String Story', album_name: 'Fretboard',       genre: 'Rock',      created_by_email: 'henry@artistms.com')
  seed_song(db, artist_id: henry_id, title: 'Power Chord',      album_name: 'Fretboard',       genre: 'Rock',      created_by_email: 'henry@artistms.com')
  seed_song(db, artist_id: henry_id, title: 'Acoustic Rain',    album_name: 'Unplugged',       genre: 'Folk',      created_by_email: 'henry@artistms.com')
end

puts 'Seed complete.'
