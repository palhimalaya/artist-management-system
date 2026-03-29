class AuthService
  def self.create_user(params)
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

  def self.find_by_email(email)
    db_connection do |db|
      result = db.exec_params(
        'SELECT * FROM users WHERE email = $1 LIMIT 1',
        [email]
      )

      return nil unless result.any?

      User.new(result.first)
    end
  end
end
