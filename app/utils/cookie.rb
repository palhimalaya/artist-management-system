require 'openssl'

module CookieUtil
  SECRET = ENV.fetch('SECRET_KEY', nil)

  def self.sign(value)
    OpenSSL::HMAC.hexdigest('SHA256', SECRET, value.to_s)
  end

  def self.generate(user_id)
    signature = sign(user_id)
    "#{user_id}|#{signature}"
  end

  def self.verify(cookie)
    return nil unless cookie

    user_id, signature = cookie.split('|')
    return nil unless user_id && signature

    return nil unless sign(user_id) == signature

    user_id
  end

  def self.parse(cookie_header)
    return {} unless cookie_header

    cookie_header.split(';').each_with_object({}) do |pair, hash|
      key, value = pair.strip.split('=', 2)
      next unless key && value

      hash[key] = value
    end
  end
end
