require 'sinatra'
require 'async_sinatra'

#class App < Sinatra::Base

#class App < Sinatra::Base
  configure do |config|
    config.register Sinatra::Async
    #alias :get :aget

  end



aget '/' do
  #EM.add_timer(5) do
  #  body "hello"
  #end
  status 201
  body "hello"
end
#end
#run App