require 'rubygems'
require './lib/mirage/client'

client = Mirage.start :port => 9001

client.stop
