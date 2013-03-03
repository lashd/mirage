require 'ostruct'
require 'json'
require 'httparty'
module Mirage
  class Template
    include HTTParty
    include Searchable

    base_uri "http://localhost:7001/mirage/templates"
    format :json

    attr_accessor :content_type, :http_method, :default, :status, :delay, :required_parameters, :required_body_content, :required_headers, :endpoint, :id
    attr_reader :value

    class << self
      def find id
        get("/#{id}")
      end
    end

    def initialize endpoint, response
      @endpoint = endpoint
      @content_type = 'text/plain'
      @value = response
      @http_method = :get
      @status = 200
      @delay = 0
      @required_parameters = {}
      @required_headers = {}
      @required_body_content = [],
          @default = false
    end

    def create
      self.class.put("/#{@endpoint}", :body => self.to_json, :headers => {"Content-Type" => "application/json"})
    end

    def delete
      self.class.delete("/#{id}")
      Request.delete "/#{id}"
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

    def headers
      headers = {}
      headers['Content-Type']=@content_type
      headers['X-mirage-method'] = @method
      headers['X-mirage-default'] = @default if @default == true
      headers['X-mirage-status'] = @status
      headers['X-mirage-delay'] = @delay
      @body_content_requirements.each_with_index do |requirement, index|
        if requirement.is_a?(Regexp)
          headers["x-mirage-required_body_content#{index}"] = "%r{#{requirement.source}}"
        else
          headers["x-mirage-required_body_content#{index}"] = requirement
        end
      end

      @request_parameter_requirements.inject(0) do |index, requirement|
        name, requirement = requirement
        if requirement.is_a?(Regexp)
          headers["x-mirage-required_parameter#{index}"] = "#{name}:%r{#{requirement.source}}"
        else
          headers["x-mirage-required_parameter#{index}"] = "#{name}:#{requirement}"
        end
        index+=1
      end

      headers
    end

    def add_body_content_requirement requirement
      @body_content_requirements << requirement
    end

    def add_request_parameter_requirement name, requirement
      @request_parameter_requirements[name] = requirement
    end

  end
end