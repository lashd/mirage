require './lib/mirage/client'

Mirage.stop
client = Mirage.start

client.put("picture", File.open("/home/team/Desktop/picture.jpg")) do |response|
  response.content_type = "image/jpeg"
  response.add_body_content_requirement "hello"
end