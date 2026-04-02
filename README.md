# Artist Management System

A web-based admin panel for managing artists, songs, and users built with Ruby, WEBrick, and PostgreSQL.

## Prerequisites

- Ruby 3.0+
- PostgreSQL 12+
- Bundler

## Setup

1. **Clone and install dependencies**

   ```bash
   git clone <repo-url>
   cd artist-management-system
   bundle install
   ```

2. **Configure environment**

   Copy `.env` and update with your PostgreSQL credentials:

   ```
   DB_NAME=artist_db
   DB_USER=postgres
   DB_PASSWORD=postgres
   SECRET_KEY=your_secret_key
   ```

3. **Create database and run migrations**

   ```bash
   ruby db/migrations/001_create_users.rb
   ruby db/migrations/002_create_artists.rb
   ruby db/migrations/003_create_songs.rb
   ruby db/migrations/004_add_indexes.rb

   or 
   ruby db/migrate.rb
   ```

4. **Seed sample data**

   ```bash
   ruby db/seeds.rb
   ```

## Running the server

```bash
ruby server.rb
```

Visit [http://localhost:3000](http://localhost:3000)

## Default login credentials

| Role           | Email               | Password |
|----------------|---------------------|----------|
| Super Admin    | admin@artistms.com  | password |
| Artist Manager | john@artistms.com   | password |
| Artist         | bob@artistms.com    | password |

## Console

```bash
ruby script/console.rb
```

Query the database from a Pry REPL:

```ruby
db = db_checkout
db.exec("SELECT id, name FROM artists").to_a
```
