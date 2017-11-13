require 'httparty'
module Mirage
  module Web

    def last_response
      @response
    end
    def response_time
      @response_time
    end

    def get(url, body: '', headers:{}, query: {})
      send_request(:get, url, query: query)
    end

    def put(url, body: '', headers:{}, query: {})
      send_request(:put, url, body: body, headers: headers, query: query)
    end

    def post(url, body: '', headers:{}, query: {})
      send_request(:post, url, body: body, headers: headers, query: query)
    end

    def delete(*args)
      send_request(:delete, *args)
    end

    private
    def send_request(http_method, url, *args)
      start_time = Time.now
      @response = HTTParty.send(http_method, url, *args).tap do
        @response_time = Time.now - start_time
      end
    end

  end
end

World(Mirage::Web)
