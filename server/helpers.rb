$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'helpers/template_requirements'
require 'helpers/http_headers'

module Mirage
  class Server < Sinatra::Base
    helpers do

      def synchronize &block
        Mutex.new.synchronize &block
      end

      def response_id
        params[:id].to_i
      end

      def prime &block
        block.call Mirage::Client.new "http://localhost:#{settings.port}"
      end

      def send_response(mock_response, body='', request={}, query_string='')
        sleep mock_response.response_spec['delay']
        content_type(mock_response.response_spec['content_type'])
        status mock_response.response_spec['status']
        headers mock_response.headers
        mock_response.value(body, request, query_string)
      end

      def tracked_requests response_id
        REQUESTS[response_id] ||= []
      end


    end
  end
end