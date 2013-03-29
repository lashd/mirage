module Mirage
  class Requests
    include HTTParty

    def initialize base_url
      @url = "#{base_url}/requests"
    end

    def delete_all
      self.class.delete(@url)
    end
  end
end
