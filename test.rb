require '/home/team/Projects/mirage/lib/mirage/client'

Mirage.start
client = Mirage::Client.new do
  http_method :post
  status 202
  default true
  delay 2
  content_type "text/xml"
end
client.clear

Mirage::Client.new.prime