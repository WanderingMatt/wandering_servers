require 'helper'

class TestRouter < Test::Unit::TestCase
  def setup
    @router = HttpServer::Router.new
  end
  
  def test_404
    io = StringIO.new("GET /flunk HTTP/1.0\r\n\r\n")
    @router.accept(io)

    response = io.string.split("\r\n")
    assert response.include?('HTTP/0.9 404 Not Found'), 'should have 404 status'
    assert response.include?('Content-Type: text/html'), "should have content type header"
    assert response.include?('<html><body><h1>404: File Not Found</h1></body></html>')    
  end
  
  def test_responds_with_file_if_it_exists
    io = StringIO.new("GET /test/#{File.basename(__FILE__)} HTTP/1.0\r\n\r\n")
    @router.accept(io)

    response = io.string.split("\r\n")
    assert response.include?('HTTP/0.9 200 OK'), 'should have 200 status'
    assert response.include?('Content-Type: text/html'), "should have content type header"
    assert response.include?(File.read(__FILE__)), "is this broken"
  end
  
  def test_routes_a_proc
    called = false
    HttpServer::Router.register '/time' do |request, response|
      called = true
      response.body = ''
    end
    
    io = StringIO.new("GET /time HTTP/1.0\r\n\r\n")
    @router.accept(io)
    
    assert called, "our proc should have been called"
  end
  
  def test_routes_a_proc_and_renders_body
    called = false
    body = "<html><body><h1>#{Time.now}</h1></body></html>"
    HttpServer::Router.register '/time' do |request, response|
      called = true
      response.status = 200
      response.headers['Content-Type'] = 'text/html'
      response.body = body
    end
    
    io = StringIO.new("GET /time HTTP/1.0\r\n\r\n")
    @router.accept(io)
    
    assert called, "our proc should have been called"

    response = io.string.split("\r\n")
    assert response.include?('Content-Type: text/html'), "should have content type header"
    assert response.include?(body)
  end
end