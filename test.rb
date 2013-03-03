require 'mirage/client'

mirage = Mirage::Client.new
mirage.templates.put("greeting","hello")