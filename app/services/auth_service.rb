class AuthService
  def self.db
    db_connection
  end

  def self.create_user(params)
    query = <<-SQL
      INSERT INTO users (first_name, email, password, role)
      VALUES ($1, $2, $3, $4)
      RETURNING *
    SQL

    result = db.exec_params(query, [
                              params['first_name'],
                              params['email'],
                              params['password'],
                              params['role']
                            ])

    User.new(result.first)
  end

  def self.find_by_email(email)
    result = db.exec_params(
      'SELECT * FROM users WHERE email = $1 LIMIT 1',
      [email]
    )

    return nil unless result.any?

    User.new(result.first)
  end
end
