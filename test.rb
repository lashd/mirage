require './lib/mirage/client'

Mirage.stop
client = Mirage.start


client.put "greeting", 'hello' do |response|
  response.http_method = :post
  response.delay = 1.2
  response.required_parameters = {:name => 'leon'}
  response.required_body_content = %w(profile)
  response.required_headers = {:header => 'value'}
end


client.put "greeting/something/hello", 'hello' do |response|
  response.http_method = :post
  response.delay = 1.2
  response.required_parameters = {:name => 'leon'}
  response.required_body_content = %w(profile)
  response.required_headers = {:header => 'value'}
end

Mirage.stop


