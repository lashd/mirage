require 'net/http'
require 'uri'
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

    class FileResponse
      attr_reader :response
      def initialize response
        @response = response
      end

      def save_as path
        @response.save_as(path)
      end
    end

    def http_put url, entity, options={}
      if options[:parameters]
        url << "?#{options[:parameters].to_a.collect{|pair|pair.join("=")}.join("&")}"
      end
      uri = URI.parse(url)
      request = Net::HTTP::Put.new(uri.request_uri)

      if entity.is_a? File
        request.body_stream=entity
        request.content_length=entity.lstat.size
      else
        request.body=entity
      end

      if options[:headers]
        options[:headers].each { |field, value| request.add_field(field, value) }
      end
      Net::HTTP.new(uri.host, uri.port).request(request)
    end

    def http_post url, params={}, headers={}
      uri = URI.parse(url)
      request = Net::HTTP::Post.new(uri.request_uri)
      
      params.is_a?(Hash) ? request.set_form_data(params) : request.body = params
        
      headers.each { |field, value| request.add_field(field, value) }
      Net::HTTP.new(uri.host, uri.port).request(request)
    end

    def http_delete url, params={}, headers={}
      uri = URI.parse(url)
      request = Net::HTTP::Delete.new(uri.request_uri)
      params.is_a?(Hash) ? request.set_form_data(params) : request.body = params
      headers.each { |field, value| request.add_field(field, value) }
      Net::HTTP.new(uri.host, uri.port).request(request)
    end

  end
end
#World(HTTParty)

World(Mirage::Web)
