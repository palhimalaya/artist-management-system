class Router
  extend ViewHelper
  extend AuthHelper

  ROUTES = [
    ['GET', '/login', view('login')],
    ['GET', '/register', view('register')],
    ['GET', '/logout', [AuthController, :logout]],
    ['POST', '/register', [AuthController, :register]],
    ['POST', '/login', [AuthController, :login]]

  ].freeze

  def call(req, res)
    ROUTES.each do |method, path, handler|
      next unless req.request_method == method

      params = match_route(path, req.path)
      next unless params

      req.instance_variable_set(:@params, params)

      return handler.call(req, res) if handler.is_a?(Proc)

      controller_class, action = handler
      controller = controller_class.new

      return controller.send(action, req, res)
    end

    not_found(res)
  end

  private

  def match_route(route_path, req_path)
    route_parts = route_path.split('/')
    req_parts = req_path.split('/')

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
