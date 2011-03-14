require 'uri'
require 'mechanize'
require 'open-uri'
require 'mirage/web'

class Mirage

  class Client
    include ::Mirage::Web

    def initialize url="http://localhost:7001/mirage"
      @url = url
    end

    def get endpoint, params={}
      http_get("#{@url}/get/#{endpoint}", params)
    end

    def set endpoint, params={}
      http_post("#{@url}/set/#{endpoint}", params)
    end

    def peek response_id
      http_get("#{@url}/peek/#{response_id}")
    end

#    client.clear 1
#    client.clear :request => 1
#    client.clear :responses
#    client.clear :requests
    def clear thing=nil
      case thing
        when NilClass then
          puts "clearing everything"
          http_get("#{@url}/clear")
        when Fixnum then
          http_get("#{@url}/clear/#{thing}")
        when :requests then
          http_get("#{@url}/clear/requests")
        when :responses then
          http_get("#{@url}/clear/responses")

        when Hash then
          case thing.keys.first
            when :request then
              http_get("#{@url}/clear/request/#{thing.values.first}")
          end
      end
    end


    def check response_id
      http_get("#{@url}/check/#{response_id}")
    end

    def snapshot
      http_post("#{@url}/snapshot")
    end

    def rollback
      http_post("#{@url}/rollback")
    end

    def running?
      !http_get(@url).is_a?(Errno::ECONNREFUSED)
    end

    def load_defaults
      http_post("#{@url}/load_defaults")
    end

  end


end