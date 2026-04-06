class User
  attr_accessor :id, :first_name, :last_name, :email, :password, :password_confirmation, :role,
                :phone, :dob, :gender, :address

  VALID_ROLES = %w[super_admin artist_manager artist].freeze
  VALID_GENDERS = %w[Male Female Other].freeze

  def initialize(attrs = {})
    @id         = attrs['id']
    @first_name = attrs['first_name']
    @last_name  = attrs['last_name']
    @email      = attrs['email']
    @password   = attrs['password']
    @password_confirmation = attrs['password_confirmation']
    @role       = attrs['role']
    @phone      = attrs['phone']
    @dob        = attrs['dob']
    @gender     = attrs['gender']
    @address    = attrs['address']
  end

  def validate(email_taken: false, require_password_confirmation: false, require_strong_password: false)
    errors = []
    validate_presence(errors)
    validate_format(errors)
    validate_optional_fields(errors)
    validate_password_confirmation(errors, require_password_confirmation)
    validate_password_strength(errors, require_strong_password)
    errors << 'Email already exists' if email_taken
    errors
  end

  def as_json(_options = {})
    {
      id: id,
      first_name: first_name,
      last_name: last_name,
      email: email,
      role: role,
      phone: phone,
      dob: dob,
      gender: gender,
      address: address
    }
  end

  def to_h
    {
      'first_name' => first_name,
      'last_name' => last_name,
      'email' => email,
      'password' => password,
      'role' => role,
      'phone' => phone,
      'dob' => dob,
      'gender' => gender,
      'address' => address
    }
  end

  private

  def blank?(value)
    value.to_s.strip.empty?
  end

  def valid_email?
    return false if blank?(email)

    email.match?(/\A[^@\s]+@[^@\s]+\z/)
  end

  def validate_presence(errors)
    errors << 'First name required' if blank?(first_name)
    errors << 'Email required' if blank?(email)
    errors << 'Password required' if blank?(password)
    errors << 'Role required' if blank?(role)
  end

  def validate_format(errors)
    errors << 'Invalid email' unless valid_email?
    errors << 'Invalid role' unless VALID_ROLES.include?(role)
  end

  def validate_optional_fields(errors)
    return if blank?(gender)

    errors << 'Invalid gender' unless VALID_GENDERS.include?(gender)
  end

  def validate_password_confirmation(errors, require_password_confirmation)
    if require_password_confirmation && blank?(password_confirmation)
      errors << 'Password confirmation required'
      return
    end

    return if blank?(password) || blank?(password_confirmation)

    errors << 'Password confirmation does not match' unless password == password_confirmation
  end

  def validate_password_strength(errors, require_strong_password)
    return unless require_strong_password
    return if blank?(password)

    unless strong_password?(password)
      errors << 'Password must be at least 8 characters and include uppercase, lowercase, number, and special character'
    end
  end

  def strong_password?(value)
    value.length >= 8 &&
      value.match?(/[A-Z]/) &&
      value.match?(/[a-z]/) &&
      value.match?(/[0-9]/) &&
      value.match?(/[^A-Za-z0-9]/)
  end
end
