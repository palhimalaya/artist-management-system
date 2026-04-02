class Router
  extend ViewHelper
  extend AuthHelper

  ROUTES = [
    # Authentication routes
    ['GET', '/', [AuthController, :root]],
    ['GET', '/login', [AuthController, :login_page]],
    ['GET', '/register', [AuthController, :register_page]],
    ['GET', '/logout', [AuthController, :logout]],
    ['POST', '/register', [AuthController, :register]],
    ['POST', '/login', [AuthController, :login]],

    # Dashboard routes
    ['GET', '/dashboard', [DashboardController, :index]],

    # User management routes
    ['GET', '/users', protected(UserController, :index, ['super_admin'])],
    ['GET', '/users/new', protected(UserController, :new, ['super_admin'])],
    ['POST', '/users', protected(UserController, :create, ['super_admin'])],
    ['GET', '/users/:id/edit', protected(UserController, :edit, ['super_admin'])],
    ['POST', '/users/:id', protected(UserController, :update, ['super_admin'])],
    ['POST', '/users/:id/delete', protected(UserController, :delete, ['super_admin'])],

    # Artist routes
    ['GET', '/artists', protected(ArtistController, :index, %w[super_admin artist_manager])],
    ['GET', '/artists/new', protected(ArtistController, :new, ['artist_manager'])],
    ['GET', '/artists/export.csv', protected(ArtistController, :export_csv, ['artist_manager'])],
    ['POST', '/artists/import.csv', protected(ArtistController, :import_csv, ['artist_manager'])],
    ['POST', '/artists', protected(ArtistController, :create, ['artist_manager'])],
    ['GET', '/artists/:id/edit', protected(ArtistController, :edit, ['artist_manager'])],
    ['POST', '/artists/:id', protected(ArtistController, :update, ['artist_manager'])],
    ['POST', '/artists/:id/delete', protected(ArtistController, :delete, ['artist_manager'])],

    # Song routes
    ['GET', '/artists/:artist_id/songs', protected(SongController, :index, %w[super_admin artist_manager artist])],
    ['GET', '/artists/:artist_id/songs/new', protected(SongController, :new, ['artist'])],
    ['POST', '/artists/:artist_id/songs', protected(SongController, :create, ['artist'])],
    ['GET', '/artists/:artist_id/songs/:id/edit', protected(SongController, :edit, ['artist'])],
    ['POST', '/artists/:artist_id/songs/:id', protected(SongController, :update, ['artist'])],
    ['POST', '/artists/:artist_id/songs/:id/delete', protected(SongController, :delete, ['artist'])]
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
