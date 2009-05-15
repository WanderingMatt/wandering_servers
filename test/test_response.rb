require 'helper'

class TestResponse < Test::Unit::TestCase
  def setup
    @response = HttpServer::Response.new
  end

  def test_can_set_response_code
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
    io = StringIO.new
    @response.status = 200
    @response.headers['Content-Type'] = 'text/html'
    @response.body = 'hello world'
    
    @response.write_to io
    io.rewind
    
    assert_equal "HTTP/0.9 200 OK\r\nContent-Type: text/html\r\nContent-Length: #{@response.body.length}\r\n\r\nhello world", io.read
  end
  
  def test_write_with_arbirary_headers
    io = StringIO.new
    @response.status = 200
    @response.headers['Content-Type'] = 'text/html'
    @response.headers['Date'] = "#{Time.now}"
    @response.body = 'hello world'
    
    @response.write_to io
    io.rewind
    
    written = io.read.split("\r\n")
    assert_equal 'HTTP/0.9 200 OK', written.first
    assert written.include?('Content-Type: text/html'), 'Should have a Content-Type header'
    assert written.include?("Content-Length: #{@response.body.length}"), 'Should have a Content-Length header'
    assert written.include?("Date: #{Time.now}"), 'Should have Date header'
  end
end