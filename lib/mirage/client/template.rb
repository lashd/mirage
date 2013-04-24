require 'ostruct'
require 'json'
require 'httparty'
require 'hashie/mash'

require 'client/template/configuration'
require 'client/template/model'

module Mirage

  class Template

    include HTTParty
    include Model::InstanceMethods

    class << self
      alias_method :backedup_get, :get

      def get url
        response_hashie = Hashie::Mash.new backedup_get(url, :format => :json)

        response_config = response_hashie.response
        request_config = response_hashie.request

        template = new(response_hashie.endpoint, response_config.body)

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
  end
end