module HttpServer
  class Request
    attr_accessor :method, :path

    def initialize io
      @io = io
      @method = nil
      @path = nil
      parse_request
    end

    def parse_request io = @io
      io.each_line do |line|
        break if line == "\r\n"
        if !@method && !@path
          parsed = line.split ' '
          @method = parsed[0]
          @path = parsed[1]
        end
      end
    end
  end
end