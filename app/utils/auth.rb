require_relative 'cookie'

module AuthUtil
  def self.current_user(req)
    cookies = CookieUtil.parse(req['Cookie'])
    user_id = CookieUtil.verify(cookies['session'])

    return nil unless user_id

    db_connection do |db|
      result = db.exec_params(
        'SELECT * FROM users WHERE id = $1 LIMIT 1',
        [user_id]
      )

      result.first
    end
  end
end
