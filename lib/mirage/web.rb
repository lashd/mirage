require 'net/http'
require 'uri'
module Mirage
  module Web
    class FileResponse
      def initialize response
        @response = response
      end

      def save_as path
        @response.save_as(path)
      end
    end

    def put url, entity, headers={}


      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Put.new(uri.request_uri)

      if entity.is_a? File
        request.body_stream=entity
        request.content_length=entity.lstat.size
      else
        request.body=entity
      end
      headers.each { |field, value| request.add_field(field, value) }
      http.request(request)
    end

    def get url, params={}
      using_mechanize do |browser|
        browser.get(url, params)
      end
    end

    def post url, params={}
      using_mechanize do |browser|
        browser.post(url, params)
      end
    end

    def delete url, params={}
      using_mechanize do |browser|
        browser.delete(url, params)
      end
    end

    def head url, params={}
#      uri = URI.parse(url)
#      head_request = Net::HTTP::Head.new(uri.path)
#      Net::HTTP.start(uri.host, uri.port) do |http|
#        http.request(head_request)
#      end
      using_mechanize do |browser|
        browser.head(url, params)
      end
    end

    def options url, params={}
      using_mechanize do |browser|
        browser.options(url, params)
      end
    end


    def http_get url, params={}
      using_mechanize do |browser|
        params[:body] ? browser.post(url, params[:body]) : browser.get(url, params)
      end
    end

    def http_post url, params={}
      using_mechanize do |browser|
        browser.post(url, params)
      end
    end

    private
    def using_mechanize
      begin
        browser = Mechanize.new
        browser.keep_alive = false
        response = yield browser

        def response.code
          @code.to_i
        end
      rescue Exception => e
        response = e

        def response.code
          self.response_code.to_i
        end

        def response.body
          ""
        end
      end
      response
    end
  end
end
