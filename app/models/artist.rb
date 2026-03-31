class Artist
  attr_accessor :id, :name, :dob, :gender, :address,
                :first_release_year, :no_of_albums_released,
                :user_id, :created_by, :linked_user_name

  def initialize(attrs = {})
    @id                     = attrs['id']
    @name                   = attrs['name']
    @dob                    = attrs['dob']
    @gender                 = attrs['gender']
    @address                = attrs['address']
    @first_release_year     = attrs['first_release_year']
    @no_of_albums_released  = attrs['no_of_albums_released']
    @user_id                = attrs['user_id']
    @created_by             = attrs['created_by']
    @linked_user_name       = attrs['linked_user_name']
  end

  def validate
    errors = []
    errors << 'Name required' if blank?(name)

    if present?(first_release_year) && !valid_integer?(first_release_year)
      errors << 'First release year must be a valid integer'
    end

    if present?(no_of_albums_released)
      val = no_of_albums_released.to_i
      errors << 'Number of albums must be >= 0' if val.negative?
    end

    errors
  end

  private

  def blank?(value)
    value.to_s.strip.empty?
  end

  def present?(value)
    !blank?(value)
  end

  def valid_integer?(value)
    Integer(value.to_s.strip)
  rescue StandardError
    false
  end
end
