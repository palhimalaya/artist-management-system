require 'jwt'

module JwtUtil
  ALGORITHM = 'HS256'.freeze
  EXPIRY_SECONDS = ENV.fetch('JWT_EXP_SECONDS', '3600').to_i
  SECRET = ENV.fetch('JWT_SECRET', ENV.fetch('SECRET_KEY', nil))

  def self.generate(user)
    now = Time.now.to_i
    payload = {
      'sub' => user.id.to_s,
      'role' => user.role,
      'iat' => now,
      'exp' => now + EXPIRY_SECONDS
    }

    JWT.encode(payload, SECRET, ALGORITHM)
  end

  def self.decode(token)
    decoded, = JWT.decode(token, SECRET, true, { algorithm: ALGORITHM })
    decoded
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end
end
