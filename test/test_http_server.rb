require 'test/unit'
require 'http_server'
require 'fileutils'

class TestHttpServer < Test::Unit::TestCase
  def setup
    @test_path = 'test.html'
    FileUtils.touch @test_path
    test_io = 'GET /#{@test_path} HTTP/1.0\r\n\r\n'
    @test_request = HttpServer::Request.new test_io
  end
  
  def teardown
    FileUtils.rm @test_path if File.exists? @test_path
  end
  
  def test_parses_file_from_request
    assert_equal '/test.html', @test_request.path
  end
  
  def test_responds_with_200_when_successful
    assert_match /200 OK/, @test_request.header
  end
  
  def test_responds_with_404_when_missing
    actual = HttpServer::Request.new 'GET /flunk.html HTTP/1.0\r\n\r\n'
    
    assert_match /404 Not Found/, actual.header
  end
end