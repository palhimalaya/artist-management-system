require 'bcrypt'

module HashUtil
  def self.hash_password(password)
    BCrypt::Password.create(password)
  end

  def self.verify_password?(password, hash)
    BCrypt::Password.new(hash) == password
  end
end
