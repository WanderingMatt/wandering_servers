require 'http_server'
require 'socket'

server = TCPServer.new 8080
router = HttpServer::Router.new
while session = server.accept
  Thread.new session do |my_session|
    router.accept my_session
    my_session.close
  end
end