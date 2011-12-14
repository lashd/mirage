require 'mirage/client'

client = Mirage::Client.new
client.put('hello', 'hello')
client.clear