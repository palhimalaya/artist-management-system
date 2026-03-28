def up(db)
  db.exec <<~SQL
    CREATE TABLE IF NOT EXISTS users (
      id SERIAL PRIMARY KEY,
      first_name VARCHAR(100),
      last_name VARCHAR(100),
      email VARCHAR(150) UNIQUE NOT NULL,
      password VARCHAR(255) NOT NULL,
      phone VARCHAR(20),
      dob DATE,
      gender VARCHAR(10),
      address TEXT,

      role VARCHAR(20) NOT NULL CHECK (
        role IN ('super_admin','artist_manager','artist')
      ),

      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
  SQL
end
