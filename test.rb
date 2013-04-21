require './lib/mirage/client'


mirage = Mirage.start

#mirage.clear
#mirage.put('some/path/greeting', 'hello') do |response|
#  response.http_method = :post
#end
#
#template = mirage.put('some/path/greeting', 'hello Michele') do |response|
#  response.http_method = :post
#  response.required_parameters['name']='Michele'
#  response.required_body_content << 'stara'
#  response.required_headers['Custom-Header']='special'
#end
#










