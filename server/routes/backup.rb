module Mirage
  class Server < Sinatra::Base
    put '/backup' do
      synchronize do
        MockResponse.backup
      end

      200
    end
  end
end