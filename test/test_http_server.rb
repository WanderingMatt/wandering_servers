require 'test/unit'
require 'http_server'

class TestHTTPServer < Test::Unit::TestCase
  def setup
    test_io = 'Hello World!'
    @test_request = Reqeust.new test_io
  end
  
  def test_responds_with_200_when_successful
    assert_match /200 OK/, @test_request.header
  end
  
  def test_responds_with_404_when_missing
    actual = Request.new 'flunk'
    
    assert_match /404 Not Found/, actual
  end
end