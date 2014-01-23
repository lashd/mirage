require 'hashie/mash'
module Mirage
  class Request
    include HTTParty

    class << self
      alias_method :backedup_get, :get
      def get url
        result = Hashie::Mash.new(backedup_get(url, format: :json))
        request = new
        request.parameters = result.parameters
        request.headers = result.headers
        request.request_url = result.request_url
        request.body = result.body
        request.id = result.id
        request
      end
    end

    attr_accessor :parameters, :headers, :body, :request_url, :id

    def delete
      self.class.delete(id)
    end
  end
end