require 'routes/defaults'
require 'routes/templates'
require 'routes/requests'
require 'routes/backup'
require 'routes/responses'
require 'routes/pid'
module Mirage
  class Server < Sinatra::Base
    get '/' do
      haml :index
    end

    put '/' do
      synchronize do
        MockResponse.revert
      end

      200
    end
  end
end