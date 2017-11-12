module Mirage
  class Template
    module Model
      module InstanceMethods
        extend Helpers::MethodBuilder
        include CommonMethods

        attr_accessor :caller_binding

        def initialize *args
          if args.last.is_a?(Template::Configuration)
            default_config = args.delete_at(-1)
          else
            default_config = Template::Configuration.new
          end

          @endpoint, @body = *args
          @content_type = default_config.content_type
          @http_method = default_config.http_method
          @status = default_config.status
          @delay = default_config.delay
          @required_parameters = {}
          @required_headers = {}
          @required_body_content = []
          @headers = {}
          @default = default_config.default
        end

        builder_method :id,
                       :url,
                       :requests_url


        def create
          @id = self.class.put("#{@endpoint}", :body => self.to_json, :headers => {'content-type' => 'application/json'})['id']
          self
        end

        def delete
          self.class.delete(url)
          Requests.delete requests_url
        end


        def to_json
          {
              :response => {
                  :body => Base64.encode64(body),
                  :status => status,
                  :default => default,
                  :content_type => content_type,
                  :headers => headers,
                  :delay => delay
              },
              :request => {
                  :parameters => encode_regexs(required_parameters),
                  :headers => encode_regexs(required_headers),
                  :body_content => encode_regexs(required_body_content),
                  :http_method => http_method,
              }
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

        def method_missing(method, *args, &block)

          if @caller_binding
            @caller_binding.send method, *args, &block
          else
            super method, *args, &block
          end

        end
      end

    end
  end
end