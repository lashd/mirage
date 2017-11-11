module Mirage
  class Server < Sinatra::Base
    error ServerResponseNotFound do
      404
    end

    error do
      erb request.env['sinatra.error'].message
    end
  end
end