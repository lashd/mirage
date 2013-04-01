require 'ostruct'
require 'json'
require 'httparty'
require 'hashie/mash'
module Mirage

  class Template
    include HTTParty

    class << self
      alias_method :backedup_get, :get

      def get url
        response_hashie = Hashie::Mash.new backedup_get(url, :format => :json)

        response_config = response_hashie.response
        request_config = response_hashie.request

        template = new(response_hashie.endpoint, response_config.body)

        template.id = response_hashie.id
        template.default = response_config['default']
        template.delay = response_config.delay
        template.content_type = response_config.content_type
        template.status = response_config.status

        template.required_parameters = request_config.parameters
        template.required_body_content = request_config.body_content
        template.http_method = request_config.http_method
        template.url = url
        template.requests_url = response_hashie.requests_url
        template.required_headers = request_config.headers

        template
      end
    end

    format :json

    attr_accessor :content_type, :http_method, :default, :status, :delay, :required_parameters, :required_body_content, :required_headers, :endpoint, :id, :url, :requests_url
    attr_reader :value


    def initialize endpoint, response, default_config=TemplateConfiguration.new

      @endpoint = endpoint
      @content_type = default_config.content_type
      @value = response
      @http_method = default_config.http_method
      @status = default_config.status
      @delay = default_config.delay
      @required_parameters = {}
      @required_headers = {}
      @required_body_content = []
      @default = default_config.default
    end

    def create
      @id = self.class.put("#{@endpoint}", :body => self.to_json, :headers => {'content-type' => 'application/json'})['id']
      self
    end

    def delete
      self.class.delete(url)
      Request.delete requests_url
    end


    def to_json
      {
          :response => {
              :body => Base64.encode64(@value),
              :status => status,
              :default => default,
              :content_type => content_type

          },
          :request => {
              :parameters => encode_regexs(required_parameters),
              :headers => encode_regexs(required_headers),
              :body_content => encode_regexs(required_body_content),
              :http_method => http_method

          },
          :delay => delay
      }.to_json
    end


    def encode_regexs hash_or_array
      case hash_or_array
        when Array
          hash_or_array.collect { |value| encode(value) }
        else
          encoded = {}
          hash_or_array.each do |key, value|
            encoded[key] = encode(value)
          end
          encoded
      end
    end

    def encode(value)
      value.is_a?(Regexp) ? "%r{#{value.source}}" : value
    end

  end
end