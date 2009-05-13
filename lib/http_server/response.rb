module HttpServer
  class Response
    attr_accessor :status, :headers, :body
    
    STATUS_CODES = {200 => 'OK', 301 => 'Moved Permanetly', 404 => 'Not Found', 500 => 'Internal Server Error'}
    
    def initialize
      @status = nil
      @headers = {}
      @body = nil
    end
    
    def write_to io
      io.write "HTTP/0.9 #{@status} #{STATUS_CODES[@status]}\r\n"
      @headers.each do |key, value|
        io.write "#{key}: #{value}\r\n"
      end
      io.write "Content-Length: #{@body.length}\r\n\r\n"
      io.write @body
    end
  end
end