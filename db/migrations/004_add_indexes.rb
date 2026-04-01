def up(db)
  db.exec <<~SQL
    CREATE INDEX IF NOT EXISTS idx_artists_name ON artists (name);
    CREATE INDEX IF NOT EXISTS idx_songs_artist_id ON songs (artist_id);
    CREATE INDEX IF NOT EXISTS idx_users_role ON users (role);
    CREATE INDEX IF NOT EXISTS idx_songs_title ON songs (title);
    CREATE INDEX IF NOT EXISTS idx_artists_created_by ON artists (created_by);
  SQL
end
