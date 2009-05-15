require 'helper'

class TestRouter < Test::Unit::TestCase
  def setup
    @router = HttpServer::Router.new
  end
  
  def test_404
    io = StringIO.new("GET /flunk HTTP/1.0\r\n\r\n")
    @router.accept(io)

    response = io.string.split("\r\n")
    assert response.include?('HTTP/0.9 404 Not Found'), 'Should have 404 status'
    assert response.include?('Content-Type: text/html'), 'Should have a Content-Type header'
    assert_match '404 File Not Found', response.last, 'Should have a 400 in the body'
  end
  
  def test_500
    called = false
    HttpServer::Router.register '/explosion' do |request, response|
      raise
    end
    io = StringIO.new("GET /explosion HTTP/1.0\r\n\r\n")
    @router.accept(io)

    response = io.string.split("\r\n")
    assert response.include?('HTTP/0.9 500 Internal Server Error'), 'Should have 404 status'
    assert response.include?('Content-Type: text/html'), 'Should have a Content-Type header'
    assert_match '500 Internal Server Error', response.last, 'Should have a 500 in the body'
  end
  
  def test_301
    io = StringIO.new("GET /date HTTP/1.0\r\n\r\n")
    @router.accept(io)

    response = io.string.split("\r\n")
    assert response.include?('HTTP/0.9 301 Moved Permanently'), 'Should have 301 status'
    assert response.include?('Content-Type: text/html'), 'Should have a Content-Type header'
    assert response.include?('Location: /time'), 'Should have a Location header'
  end
  
  def test_routes_a_proc
    called = false
    HttpServer::Router.register '/time' do |request, response|
      called = true
      response.body = ''
    end
    
    io = StringIO.new("GET /time HTTP/1.0\r\n\r\n")
    @router.accept(io)
    
    assert called, 'Our proc should have been called'
  end
  
  def test_routes_a_proc_and_renders_body
    called = false
    HttpServer::Router.register '/time' do |request, response|
      called = true
      response.status = 200
      response.headers['Content-Type'] = 'text/html'
      response.body = "<html><body><h1>#{Time.now}</h1></body></html>"
    end
    
    io = StringIO.new("GET /time HTTP/1.0\r\n\r\n")
    @router.accept(io)
    
    assert called, 'Our proc should have been called'

    response = io.string.split("\r\n")
    assert response.include?('Content-Type: text/html'), 'Should have a Content-Type header'
    assert_match "#{Time.now}", response.last, 'Should have the time in the body'
    
  end
  
  def test_responds_with_directories
    io = StringIO.new("GET /test/ HTTP/1.0\r\n\r\n")
    @router.accept(io)
    
    response = io.string.split("\r\n")
    assert response.include?('HTTP/0.9 200 OK'), 'Should have 200 status'
    assert response.include?('Content-Type: text/html'), 'Should have a Content-Type header'
    assert_match "#{File.basename(__FILE__)}", response.last, 'Should list this file in the body'
  end
  
  def test_responds_with_files
    io = StringIO.new("GET /test/#{File.basename(__FILE__)} HTTP/1.0\r\n\r\n")
    @router.accept(io)

    response = io.string.split("\r\n")
    assert response.include?('HTTP/0.9 200 OK'), 'Should have 200 status'
    assert response.include?('Content-Type: text/html'), 'Should have a Content-Type header'
    assert response.include?(File.read(__FILE__)), 'Should return this file in the body'
  end
  
  def test_html_content_type
    actual = @router.content_type "test.html"
    expected = "text/html"
    assert_equal expected, actual
  end
 
  def test_erb_content_type
    actual = @router.content_type "test.html.erb"
    expected = "text/html"
    assert_equal expected, actual
  end
 
  def test_rb_content_type
    actual = @router.content_type "test.rb"
    expected = "text/plain"
    assert_equal expected, actual
  end
 
  def test_missing_content_type
    actual = @router.content_type "noext"
    expected = "text/plain"
    assert_equal expected, actual
  end
 
  def test_erb_gets_rendered
    io = StringIO.new("GET /test/test.html.erb HTTP/1.0\r\n\r\n")
    @router.accept(io)
 
    response = io.string.split("\r\n")
    erb = ERB.new(File.read('./test/test.html.erb')).src
 
    assert response.include?('HTTP/0.9 200 OK'), 'should have 200 status code'
    assert response.include?('Content-Type: text/html'), "should have content type header"
    assert response.include?(eval(erb,binding)), "has the html-ified version of the ERB file"
    assert_match(/This\sis\snot\sa\srandom\svariable/, response.last)
  end
end