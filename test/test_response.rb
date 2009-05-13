require 'helper'

class TestResponse < Test::Unit::TestCase
  def setup
    @response = HttpServer::Response.new
  end

  def test_status_is_nil_on_init
    assert_nil @response.status
  end

  def test_body_is_nil_on_init
    assert_nil @response.body
  end

  def test_response_code_can_be_set
    @response.status = 200
    assert_equal 200, @response.status
  end
  
  def test_can_set_body
    @response.body = 'hello world'
    assert_equal 'hello world', @response.body
  end
  
  def test_response_holds_headers
    @response.headers['Content-Type'] = 'text/html'
    assert_equal 'text/html', @response.headers['Content-Type']
  end
  
  def test_write_to
    content = 'hello world'
    string_io = StringIO.new
    @response.status = 200
    @response.body = content
    @response.headers['Content-Type'] = 'text/html'
    
    @response.write_to(string_io)
    
    string_io.rewind
    assert_equal "HTTP/0.9 200 OK\r\nContent-Type: text/html\r\nContent-Length: #{content.length}\r\n\r\n#{content}",
      string_io.read
  end
  
  def test_write_with_arbirary_headers
    body = '<html><body>hello world</body></html>'
    io = StringIO.new
    @response.status = 200
    @response.body = body
    @response.headers['Content-Type'] = 'text/html'
    @response.headers['Date'] = 'today!'
    
    @response.write_to io
    
    io.rewind
    
    written = io.read.split("\r\n")
    assert_equal 'HTTP/0.9 200 OK', written.first
    assert written.include?('Date: today!'), 'should have date header'
    assert written.include?('Content-Type: text/html'), 'should have content type'
    assert written.include?("Content-Length: #{body.length}"), 'should have content length'
  end
end