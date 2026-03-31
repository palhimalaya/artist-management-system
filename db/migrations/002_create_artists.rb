def up(db)
  db.exec <<~SQL
    CREATE TABLE IF NOT EXISTS artists (
      id SERIAL PRIMARY KEY,
      name VARCHAR(150) NOT NULL,
      dob DATE,
      gender VARCHAR(10),
      address TEXT,
      first_release_year INT,
      no_of_albums_released INT DEFAULT 0,

      user_id INTEGER UNIQUE REFERENCES users(id) ON DELETE SET NULL,

      created_by INTEGER REFERENCES users(id) ON DELETE SET NULL,

      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
  SQL
end
