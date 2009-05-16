require 'http_server'
require 'socket'

THREAD_LIMIT = 5

server = TCPServer.new 8080
router = HttpServer::Router.new
thread_pool = []
while session = server.accept
  if thread_pool.size < THREAD_LIMIT
    thread_pool << Thread.new(session) do |my_session|
      router.accept my_session
      my_session.close
      # sleep 3
      thread_pool.delete Thread.current
    end
  end
end