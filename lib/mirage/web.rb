require 'net/http'
require 'uri'
module Mirage
  module Web
    class FileResponse
      attr_reader :response
      def initialize response
        @response = response
      end

      def save_as path
        @response.save_as(path)
      end
    end

    def put url, entity, headers={}
      uri = URI.parse(url)
      request = Net::HTTP::Put.new(uri.request_uri)

      if entity.is_a? File
        request.body_stream=entity
        request.content_length=entity.lstat.size
      else
        request.body=entity
      end
      headers.each { |field, value| request.add_field(field, value) }
      
      Net::HTTP.new(uri.host, uri.port).request(request)
    end

    def get url, params={}, headers={}
      uri = URI.parse(url)
      request = Net::HTTP::Get.new(uri.request_uri)
      request.set_form_data params
      headers.each { |field, value| request.add_field(field, value) }
      Net::HTTP.new(uri.host, uri.port).request(request)
    end

    def post url, params={}, headers={}
      uri = URI.parse(url)
      request = Net::HTTP::Post.new(uri.request_uri)
      
      params.is_a?(Hash) ? request.set_form_data(params) : request.body = params
        
      headers.each { |field, value| request.add_field(field, value) }
      Net::HTTP.new(uri.host, uri.port).request(request)
    end

    def delete url, params={}, headers={}
      uri = URI.parse(url)
      request = Net::HTTP::Delete.new(uri.request_uri)
      params.is_a?(Hash) ? request.set_form_data(params) : request.body = params
      headers.each { |field, value| request.add_field(field, value) }
      Net::HTTP.new(uri.host, uri.port).request(request)
    end

  end
end
