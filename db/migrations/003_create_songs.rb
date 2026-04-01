def up(db)
  db.exec <<~SQL
    CREATE TABLE IF NOT EXISTS songs (
      id SERIAL PRIMARY KEY,

      artist_id INTEGER NOT NULL
        REFERENCES artists(id) ON DELETE CASCADE,

      title VARCHAR(200) NOT NULL,
      album_name VARCHAR(200),
      genre VARCHAR(50),

      created_by INTEGER REFERENCES users(id) ON DELETE SET NULL,

      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
  SQL
end
