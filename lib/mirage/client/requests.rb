module Mirage
  class Requests
    include HTTParty

    def initialize base_url
      @base_url = base_url
    end

    def delete_all
      self.class.delete(@base_url)
    end
  end
end
