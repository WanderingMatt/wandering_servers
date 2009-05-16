require 'http_server'
require 'gserver'

class WanderingGServer < GServer
  include HttpServer
  def initialize port = 8080, *args
    super
  end
  def serve io
    server = HttpServer::Router.new
    server.accept io
  end
end

server = WanderingGServer.new
server.audit = true
server.start
server.join