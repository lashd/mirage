require './lib/mirage/client'

mirage = Mirage.start
mirage.templates.delete_all

mirage.templates.put('greeting', 'hello') do |response|
  response.required_headers['custom-header'] = /.eon/
end