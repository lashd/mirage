require 'httparty'
module Mirage
  module Web
    def get *args
      HTTParty.get(*args)
    end
    def put *args
      HTTParty.put(*args)
    end
    def post *args
      HTTParty.post(*args)
    end
    def delete *args
      HTTParty.delete(*args)
    end
  end
end

World(Mirage::Web)
