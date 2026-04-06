class UserService
  def self.blank_to_nil(value)
    value.to_s.strip.empty? ? nil : value
  end

  def self.find(id)
    db_connection do |db|
      result = db.exec_params(
        'SELECT * FROM users WHERE id = $1 LIMIT 1',
        [id]
      )

      return nil unless result.any?

      User.new(result.first)
    end
  end

  def self.count
    db_connection do |db|
      result = db.exec_params('SELECT COUNT(*) AS total FROM users')
      result.first['total'].to_i
    end
  end

  def self.all(limit: 10, offset: 0)
    db_connection do |db|
      result = db.exec_params(
        'SELECT * FROM users ORDER BY id ASC LIMIT $1 OFFSET $2',
        [limit, offset]
      )

      result.map { |row| User.new(row) }
    end
  end

  def self.create(params)
    query = <<-SQL
      INSERT INTO users (first_name, last_name, email, password, phone, dob, gender, address, role)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
      RETURNING *
    SQL

    db_connection do |db|
      result = db.exec_params(query, [
                                params['first_name'],
                                blank_to_nil(params['last_name']),
                                params['email'],
                                params['password'],
                                blank_to_nil(params['phone']),
                                blank_to_nil(params['dob']),
                                blank_to_nil(params['gender']),
                                blank_to_nil(params['address']),
                                params['role']
                              ])

      User.new(result.first)
    end
  end

  def self.update(id, params)
    query = <<-SQL
      UPDATE users
      SET first_name = $1,
          last_name = $2,
          email = $3,
          phone = $4,
          dob = $5,
          gender = $6,
          address = $7,
          role = $8
      WHERE id = $9
      RETURNING *
    SQL

    db_connection do |db|
      result = db.exec_params(query, [
                                params['first_name'],
                                blank_to_nil(params['last_name']),
                                params['email'],
                                blank_to_nil(params['phone']),
                                blank_to_nil(params['dob']),
                                blank_to_nil(params['gender']),
                                blank_to_nil(params['address']),
                                params['role'],
                                id
                              ])

      return nil unless result.any?

      User.new(result.first)
    end
  end

  def self.delete(id)
    db_connection do |db|
      db.exec_params(
        'DELETE FROM users WHERE id = $1',
        [id]
      )
    end
  end
end
