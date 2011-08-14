$LOAD_PATH.unshift "#{File.dirname(__FILE__)}"
require 'client'
require 'sinatra/base'
require 'object'
require 'mock_response'
require 'mock_responses_collection'


module Mirage

  class Server < Sinatra::Base

    REQUESTS= {}

    MOCK_RESPONSES = MockResponsesCollection.new

    put '/mirage/templates/*' do |name|
      response = request.body.read

      headers = request.env
      http_method = headers['HTTP_X_MIRAGE_METHOD'] || 'GET'

      pattern = headers['HTTP_X_MIRAGE_PATTERN'] ? /#{headers['HTTP_X_MIRAGE_PATTERN']}/ : :basic

      MOCK_RESPONSES << MockResponse.new(name, response, headers['CONTENT_TYPE'], http_method, pattern, headers['HTTP_X_MIRAGE_DELAY'].to_f, headers['HTTP_X_MIRAGE_DEFAULT'], headers['HTTP_X_MIRAGE_FILE'])
    end

    ['get', 'post', 'delete', 'put'].each do |http_method|
      send(http_method, '/mirage/responses/*') do |name|
        body, query_string = Rack::Utils.unescape(request.body.read.to_s), request.env['QUERY_STRING']
        record = MOCK_RESPONSES.get_response(name, http_method, body, query_string)

        return 404 unless record
        REQUESTS[record.response_id] = body.empty? ? query_string : body

        sleep record.delay
        send_response(record, body, request, query_string)
      end
    end

    delete '/mirage/templates/:id' do
      response_id = params[:id].to_i
      MOCK_RESPONSES.delete(response_id)
      REQUESTS.delete(response_id)
    end

    delete '/mirage/requests' do
      REQUESTS.clear
    end

    delete '/mirage/requests/:id' do
      REQUESTS.delete(params[:id].to_i)
    end


    delete '/mirage/templates' do
      [REQUESTS].each { |map| map.clear }
      MOCK_RESPONSES.clear
      MockResponse.reset_count
    end

    get '/mirage/templates/:id' do
      response = MOCK_RESPONSES.find(params[:id].to_i)
      return 404 if response.is_a? Array
      send_response(response)
    end

    get '/mirage/requests/:id' do
      REQUESTS[params[:id].to_i] || 404
    end


    get '/mirage' do
      @responses = {}

      MOCK_RESPONSES.all.each do |response|
        pattern = response.pattern.is_a?(Regexp) ? "pattern = #{response.pattern.source}" : ''
        delay = response.delay > 0 ? "delay = #{response.delay}" : ''
        pattern << ' ,' unless pattern.empty? || delay.empty?
        @responses["#{response.name}#{'/*' if response.default?}: #{pattern} #{delay}"] = response
      end
      erb :index
    end

    error do
      erb request.env['sinatra.error'].message
    end

    put '/mirage/defaults' do
      MOCK_RESPONSES.clear

      Dir["#{settings.defaults_directory}/**/*.rb"].each do |default|
        begin
          eval File.read(default)
        rescue Exception => e
          raise "Unable to load default responses from: #{default}"
        end

      end
    end
#
    put '/mirage/backup' do
      MOCK_RESPONSES.backup
    end


    put '/mirage' do
      MOCK_RESPONSES.revert
    end


    helpers do
      
      def prime &block
        yield Mirage::Client.new "http://localhost:#{settings.port}/mirage" 
      end

      def response_value
        return request['response'] unless request['response'].nil?
      end

      def send_response(response, body='', request={}, query_string='')
        content_type(response.content_type)
        response.value(body, request, query_string)
      end
    end
  end
end