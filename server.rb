require 'webrick'
require_relative 'config/boot'
require_relative 'routes/router'

server = WEBrick::HTTPServer.new(Port: 3000)
db_connection { |_| }
router = Router.new
public_dir = File.expand_path('public', __dir__)

server.mount_proc '/' do |req, res|
  requested_path = WEBrick::HTTPUtils.unescape(req.path).sub(%r{\A/}, '')
  static_file = File.expand_path(requested_path, public_dir)

  if static_file.start_with?(public_dir) && File.file?(static_file)
    res.status = 200
    res['Content-Type'] = WEBrick::HTTPUtils.mime_type(static_file, WEBrick::HTTPUtils::DefaultMimeTypes)
    res.body = File.binread(static_file)
    next
  end

  router.call(req, res)
end

trap('INT') { server.shutdown }

puts 'Server running on http://localhost:3000'
server.start
