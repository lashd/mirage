module Mirage

  class Server < Sinatra::Base
    put '/defaults' do
      synchronize do
        MockResponse.delete_all
        if File.directory?(settings.defaults.to_s)
          Dir["#{settings.defaults}/**/*.rb"].each do |default|
            begin
              eval File.read(default)
            rescue Exception => e
              raise "Unable to load default responses from: #{default}"
            end
          end
        end
      end
      200
    end
  end
end
