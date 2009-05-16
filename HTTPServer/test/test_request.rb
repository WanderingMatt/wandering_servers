require 'helper'

class TestRequest < Test::Unit::TestCase
  def setup
    @test_io = StringIO.new "GET /#{File.basename(__FILE__)} HTTP/1.0\r\nHost: flunk.com\r\nDate: today\r\n\r\nhello world"
    @test_request = HttpServer::Request.new @test_io
  end

  def test_parses_method_from_request
    assert_equal 'GET', @test_request.method
  end

  def test_parses_file_from_request
    assert_equal "/#{File.basename(__FILE__)}", @test_request.path
  end

  def test_read_stops_after_double_crlf
    assert_equal 'hello world', @test_io.read
  end
end