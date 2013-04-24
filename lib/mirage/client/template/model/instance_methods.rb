module Mirage
  class Template
    module Model
      module InstanceMethods
        extend Helpers::Builder

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
          @headers = {}
          @default = default_config.default
        end

        builder_method :content_type,
                       :http_method,
                       :default,
                       :status,
                       :delay,
                       :required_parameters,
                       :required_body_content,
                       :required_headers,
                       :endpoint,
                       :id,
                       :url,
                       :requests_url,
                       :headers,
                       :value

        def create
          @id = self.class.put("#{@endpoint}", :body => self.to_json, :headers => {'content-type' => 'application/json'})['id']
          self
        end

        def delete
          self.class.delete(url)
          Request.delete requests_url
        end


        def to_json
          result = {
              :response => {
                  :body => Base64.encode64(value),
                  :status => status,
                  :default => default,
                  :content_type => content_type,
                  :headers => headers

              },
              :request => {
                  :parameters => encode_regexs(required_parameters),
                  :headers => encode_regexs(required_headers),
                  :body_content => encode_regexs(required_body_content),
                  :http_method => http_method,
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
  end
end