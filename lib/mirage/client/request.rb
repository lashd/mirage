require 'hashie/mash'
module Mirage
  class Request
    include HTTParty
    attr_accessor :parameters, :headers, :body, :request_url, :id

    def delete
      self.class.delete(id)
    end
  end
end