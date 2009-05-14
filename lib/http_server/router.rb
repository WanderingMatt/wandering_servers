module HttpServer
  class Router
    SERVLETS = {}
    ROOT = Dir.pwd
    
    def self.register path, &block
      SERVLETS[path] = block
    end
    
    def accept io
      request = Request.new io
      response = Response.new
      
      if SERVLETS.key? request.path
        SERVLETS[request.path].call request, response
        response.write_to io
        
      else
        serve_file(request.path, response).write_to io
      end
    end
    
    def serve_file path, response
      file = ROOT + path
      if File.exists? file
        response.status = 200
        response.headers['Content-Type'] = 'text/html'
        response.body = File.read(file)
      else
        response.status = 404
        response.headers['Content-Type'] = 'text/html'
        response.body = "<html><body><h1>404: File Not Found</h1></body></html>"
      end
      response
    end
  end
end

HttpServer::Router.register '/time' do |request, response|
  called = true
  response.status = 200
  response.headers['Content-Type'] = 'text/html'
  response.body = "<html><body><h1>#{Time.now}</h1></body></html>"
end