class UserService
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
      INSERT INTO users (first_name, email, password, role)
      VALUES ($1, $2, $3, $4)
      RETURNING *
    SQL

    db_connection do |db|
      result = db.exec_params(query, [
                                params['first_name'],
                                params['email'],
                                params['password'],
                                params['role']
                              ])

      User.new(result.first)
    end
  end

  def self.update(id, params)
    query = <<-SQL
      UPDATE users
      SET first_name = $1,
          email = $2,
          role = $3
      WHERE id = $4
      RETURNING *
    SQL

    db_connection do |db|
      result = db.exec_params(query, [
                                params['first_name'],
                                params['email'],
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
