require_relative 'cookie'
require_relative 'jwt'

module AuthUtil
  def self.current_user(req)
    user_id = bearer_user_id(req) || cookie_user_id(req)
    return nil unless user_id

    find_user(user_id)
  end

  def self.bearer_user_id(req)
    auth_header = req['Authorization'].to_s
    return nil unless auth_header.start_with?('Bearer ')

    token = auth_header.split(' ', 2).last.to_s
    payload = JwtUtil.decode(token)
    payload && payload['sub']
  end

  def self.cookie_user_id(req)
    cookies = CookieUtil.parse(req['Cookie'])
    CookieUtil.verify(cookies['session'])
  end

  def self.find_user(user_id)
    db_connection do |db|
      result = db.exec_params(
        'SELECT * FROM users WHERE id = $1 LIMIT 1',
        [user_id]
      )

      result.first
    end
  end
end
