require 'rubygems'
require 'mirage/client'


client = Mirage::Client.new
client.put('greeting', 'hello')
client.save
client.put('leaving', 'goodbye')

