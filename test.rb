require 'mirage/client'

mirage = Mirage::Client.new
puts mirage.templates.put("greeting","hello")