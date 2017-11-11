module Mirage
  class Server < Sinatra::Base
    get '/pid' do
      "#{$$}"
    end
  end
end