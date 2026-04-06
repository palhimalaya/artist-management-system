module AuthHelper
  def require_auth(req, res)
    raw_user = AuthUtil.current_user(req)

    unless raw_user
      if json_request?(req)
        json_response(res, { error: 'Unauthorized' }, status: 401)
      else
        res.status = 302
        res['Location'] = '/login'
      end
      return nil
    end

    user = User.new(raw_user)
    req.instance_variable_set(:@current_user, user)
    user
  end

  def authorize(req, res, allowed_roles)
    user = require_auth(req, res)
    return unless user

    unless allowed_roles.include?(user.role)
      if json_request?(req)
        json_response(res, { error: 'Forbidden' }, status: 403)
      else
        res.status = 403
        render_view(res, 'app/views/authorized.html.erb')
      end
      return nil
    end

    user
  end

  def protected(controller_class, action, roles)
    lambda do |req, res|
      controller = controller_class.new

      user = controller.authorize(req, res, roles)
      next unless user

      controller.send(action, req, res)
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
