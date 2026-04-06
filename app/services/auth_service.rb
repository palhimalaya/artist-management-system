class AuthService
  def self.blank_to_nil(value)
    value.to_s.strip.empty? ? nil : value
  end

  def self.create_user(params)
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
