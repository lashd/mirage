require 'ostruct'
require 'json'
require 'httparty'
require 'hashie/mash_ext'

require 'client/template/configuration'
require 'client/template/model'

module Mirage

  class Template

    include HTTParty
    include Model::InstanceMethods
    include Model::CommonMethods

    class << self
      alias_method :backedup_get, :get

      def get url
        response = backedup_get(url, :format => :json)
        raise TemplateNotFound if response.code == 404
        response_hashie = Hashie::Mash.new response

        response_config = response_hashie.response
        request_config = response_hashie.request

        template = new(response_hashie.endpoint, Base64.decode64(response_config.body))

        template.id response_hashie.id
        template.default response_config['default']
        template.delay response_config.delay
        template.content_type response_config.content_type
        template.status response_config.status
        template.headers response_config.headers

        template.required_parameters request_config.parameters
        template.required_body_content request_config.body_content
        template.http_method request_config.http_method
        template.url url
        template.requests_url response_hashie.requests_url
        template.required_headers request_config.headers

        template
      end
    end

    def initialize *args
      endpoint = args.first

      raise ArgumentError, "You must specify a string endpoint as the first argument" unless endpoint && endpoint.is_a?(String)
      super *args

    end
  end
end