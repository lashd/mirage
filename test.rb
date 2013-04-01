require './lib/mirage/client'
Mirage.stop
mirage = Mirage.start
puts Mirage::Client.new.requests(1).parameters