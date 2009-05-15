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
      begin
        if SERVLETS.key? request.path
          SERVLETS[request.path].call request, response
          response.write_to io
        else
          serve(request.path, response).write_to io
        end
      rescue => detail
        response.status = 500
        response.headers['Content-Type'] = 'text/html'
        response.body = "<html><body><h1>500 Internal Server Error</h1><h2>#{detail.to_s}</h2></body></html>"
        response.write_to io
      end
    end
    
    def serve path, response
      lookup = ROOT + path
      if File.directory? lookup
        serve_directory lookup, response
      elsif File.exists? lookup
        serve_file lookup, response
      else
        serve_404 path, response
      end
      response
    end
    
    def serve_directory dir, response
      response.status = 200
      response.headers['Content-Type'] = 'text/html'
      items = Dir.new(dir).entries.reject{ |f| f =~ /^\./ }
       response.body = "<html><head></head><body><ul style=\"list-style-type:none;margin:0;padding:0;\">"
       items.each do |item|
         response.body << "<li>"
         response.body += File.directory?(item) ? "<strong>#{item}/</strong>" : "#{item}"
         response.body += "</li>"
       end
       response.body += "</ul></body></html>"
     end
    
    def serve_file file, response
      response.status = 200
      response.headers['Content-Type'] = content_type file
      response.body = File.read(file)
      response
    end
    
    def serve_404 path, response
      response.status = 404
      response.headers['Content-Type'] = 'text/html'
      response.body = "<html><body><h1>404 File Not Found</h1></body></html>"
      response
    end
    
    def content_type file
      ext = File.extname file
      if ext == '.html' || ext == '.erb'
        'text/html'
      else
        'text/plain'
      end
    end
  end
end