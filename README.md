# Artist Management System

A web-based admin panel for managing artists, songs, and users built with Ruby, WEBrick, and PostgreSQL.

## Highlights

- Raw SQL based CRUD (no ORM)
- Relational database with `users`, `artists`, and `songs` tables
- Authentication with login/logout and session cookie
- Role-based dashboard access
- Pagination for list pages
- CSV import/export for artists

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

   Create a `.env` file in the project root and add:

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

## Role Access

| Module | Action | Allowed Role(s) |
|---|---|---|
| Auth | Register | Public (creates `artist` role only) |
| Auth | Login/Logout | All authenticated users |
| Users | List/Create/Update/Delete | `super_admin` |
| Artists | List | `super_admin`, `artist_manager` |
| Artists | Create/Update/Delete | `artist_manager` |
| Artists | CSV Import/Export | `artist_manager` |
| Songs (per artist) | List | `super_admin`, `artist_manager`, linked `artist` |
| Songs (per artist) | Create/Update/Delete | linked `artist` only |

## Registration and Admin Policy

- Public signup (`/register`) creates `artist` users only.
- `super_admin` is bootstrapped using seed data.
- Administrative user management is done from dashboard by `super_admin`.

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
