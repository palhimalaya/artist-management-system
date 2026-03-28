require 'webrick'
require_relative 'routes/router'

server = WEBrick::HTTPServer.new(Port: 3000)

server.mount_proc '/' do |req, res|
  Router.call(req, res)
end

trap('INT') { server.shutdown }

puts 'Server running on http://localhost:3000'
server.start
