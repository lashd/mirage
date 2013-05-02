require './lib/mirage/client'


Mirage.stop
mirage = Mirage.start


mirage.put('FindCis.do', 'value1') do
  http_method :post
  content_type "text/xml"
  required_body_content ['value']
  status 200
end

mirage.put('FindCis.do', 'value2') do
  http_method :post
  content_type "text/xml"
  required_body_content ['value']
  status 200
end