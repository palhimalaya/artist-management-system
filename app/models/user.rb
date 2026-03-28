class User
  attr_accessor :id, :first_name, :email, :password, :role

  VALID_ROLES = %w[super_admin artist_manager artist].freeze

  def initialize(attrs = {})
    @id         = attrs['id']
    @first_name = attrs['first_name']
    @email      = attrs['email']
    @password   = attrs['password']
    @role       = attrs['role']
  end

  def validate
    errors = []
    validate_presence(errors)
    validate_format(errors)
    errors
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
end
