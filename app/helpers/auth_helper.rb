module AuthHelper
  def require_auth(req, res)
    user = AuthUtil.current_user(req)

    unless user
      res.status = 302
      res['Location'] = '/login'
      return nil
    end

    req.instance_variable_set(:@current_user, user)
    user
  end

  def protected(handler)
    lambda do |req, res|
      user = require_auth(req, res)
      next unless user

      handler.call(req, res)
    end
  end

  def protected_view(name)
    lambda do |req, res|
      user = require_auth(req, res)
      next unless user

      render_view(res, "app/views/#{name}.html")
    end
  end
end
