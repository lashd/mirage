module Mirage
  class Requests < Array
    class NotReceivedException < StandardError ; end

    include HTTParty

    class << self
      alias_method :backedup_get, :get
      def get url
        response = backedup_get(url, format: :json)
        requests = new(url)
        response.each do |request_data|
          request_data_hash = Hashie::Mash.new(request_data)
          request = Request.new
          request.parameters = request_data_hash.parameters
          request.headers = request_data_hash.headers
          request.request_url = request_data_hash.request_url
          request.body = request_data_hash.body
          request.id = request_data_hash.id
          requests << request
        end
        requests
      rescue Exception => e
        raise NotReceivedException.new('Mirage has not received a request for this id')
      end
    end

    def initialize base_url
      @url = base_url
    end

    def delete_all
      self.class.delete(@url)
    end

    alias delete delete_all
  end
end
