require 'json'

class Router
  def self.call(req, res)
    res['Content-Type'] = 'application/json'

    if req.path == '/test'
      res.body = { message: 'API working' }.to_json
    else
      res.status = 404
      res.body = { error: 'Not Found' }.to_json
    end
  end
end
