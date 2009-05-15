HttpServer::Router.register '/time' do |request, response|
  called = true
  response.status = 200
  response.headers['Content-Type'] = 'text/html'
  response.body = "<html><body><h1>#{Time.now}</h1></body></html>"
end

# REDIRECTS

HttpServer::Router.register '/date' do |request, response|
  called = true
  response.status = 301
  response.headers['Location'] = '/time'
end