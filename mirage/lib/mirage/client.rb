require 'uri'
require 'mechanize'
require 'open-uri'
require 'mirage/web'

module Mirage

  class MirageError < ::Exception
    attr_reader :code

    def initialize message, code
      super message
      @code = message, code
    end
  end

  class InternalServerException < MirageError;
  end

  class ResponseNotFound < MirageError;
  end

  class Client
    include ::Mirage::Web

    def initialize url="http://localhost:7001/mirage"
      @url = url
    end

    def get endpoint, params={}
      response(http_get("#{@url}/get/#{endpoint}", params))
    end

    def set endpoint, params
      response(http_post("#{@url}/set/#{endpoint}", params))
    end

    def peek response_id
      response(http_get("#{@url}/peek/#{response_id}"))
    end

    def clear thing=nil
      case thing
        when NilClass then
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


    def inspect response_id
      response(http_get("#{@url}/inspect/#{response_id}"))
    end

    def snapshot
      http_post("#{@url}/snapshot").code == 200
    end

    def rollback
      http_post("#{@url}/rollback").code == 200
    end

    def running?
      !http_get(@url).is_a?(Errno::ECONNREFUSED)
    end

    def load_defaults
      response(http_post("#{@url}/load_defaults"))
    end

    private
    def response response
      return Mirage::Web::File.new(response) if response.instance_of?(Mechanize::File)
      case response.code
        when 500 then
          raise ::Mirage::InternalServerException.new(response.page.body, response.code)
        when 404 then
          raise ::Mirage::ResponseNotFound.new(response.page.body, response.code)
        else
          response.body
      end
    end

  end


end