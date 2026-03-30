class Router
  extend ViewHelper
  extend AuthHelper

  ROUTES = [
    ['GET', '/', lambda { |req, res|
      user = require_auth(req, res)

      res.status = 302
      res['Location'] = user ? '/dashboard' : '/login'
    }],
    ['GET', '/login', view('login')],
    ['GET', '/register', view('register')],
    ['GET', '/logout', [AuthController, :logout]],
    ['POST', '/register', [AuthController, :register]],
    ['POST', '/login', [AuthController, :login]],

    ['GET', '/dashboard', [DashboardController, :index]],
    ['GET', '/users', protected(UserController, :index, ['super_admin'])],
    ['GET', '/users/new', protected(UserController, :new, ['super_admin'])],
    ['POST', '/users', protected(UserController, :create, ['super_admin'])],
    ['GET', '/users/:id/edit', protected(UserController, :edit, ['super_admin'])],
    ['POST', '/users/:id', protected(UserController, :update, ['super_admin'])],
    ['POST', '/users/:id/delete', protected(UserController, :delete, ['super_admin'])]
  ].freeze

  def call(req, res)
    matched = nil

    ROUTES.each do |method, path, handler|
      next unless req.request_method.upcase == method

      params = match_route(path, req.path)
      next unless params

      matched = [handler, params]
      break
    end

    if matched
      handler, params = matched
      req.define_singleton_method(:params) { params }
      dispatch(handler, req, res)
    else
      not_found(res)
    end
  end

  private

  def dispatch(handler, req, res)
    if handler.is_a?(Proc)
      handler.call(req, res)
    else
      controller_class, action = handler
      controller = controller_class.new
      controller.send(action, req, res)
    end
  end

  def match_route(route_path, req_path)
    route_parts = route_path.split('/').reject(&:empty?)
    req_parts = req_path.split('/').reject(&:empty?)

    return nil unless route_parts.length == req_parts.length

    params = {}

    route_parts.zip(req_parts).each do |route_part, req_part|
      if route_part.start_with?(':')
        params[route_part[1..]] = req_part
      elsif route_part != req_part
        return nil
      end
    end

    params
  end

  def not_found(res)
    res.status = 404
    res['Content-Type'] = 'text/plain'
    res.body = '404 Not Found'
  end
end
