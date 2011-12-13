require 'rubygems'
$0='Mirage Server'
ROOT_DIR = File.dirname(__FILE__)
$LOAD_PATH.unshift("#{ROOT_DIR}/lib")
$LOAD_PATH.unshift("#{ROOT_DIR}/server")

require 'sinatra/base'

require 'extensions/object'
require 'mock_response'
require 'mock_responses'
require 'util'

require 'mirage/client'

include Mirage::Util

module Mirage

  class Server < Sinatra::Base

    configure do
      options = parse_options(ARGV)
      set :defaults_directory, options[:defaults_directory]
      set :port, options[:port]
      set :show_exceptions, false
      set :logging, true
      set :server, 'webrick'
      set :views, "#{ROOT_DIR}/views"

      log_file = File.open('mirage.log', 'a')
      log_file.sync=true
      use Rack::CommonLogger, log_file
      enable :logging
    end

    REQUESTS= {}

    put '/mirage/templates/*' do |name|
      response = request.body.read

      headers = request.env
      http_method = headers['HTTP_X_MIRAGE_METHOD'] || 'GET'

      pattern = headers['HTTP_X_MIRAGE_PATTERN'] ? /#{headers['HTTP_X_MIRAGE_PATTERN']}/ : :basic

      MockResponses << MockResponse.new(name, response, headers['CONTENT_TYPE'], http_method, pattern, headers['HTTP_X_MIRAGE_DELAY'].to_f, headers['HTTP_X_MIRAGE_DEFAULT'], headers['HTTP_X_MIRAGE_FILE'])
    end

    ['get', 'post', 'delete', 'put'].each do |http_method|
      send(http_method, '/mirage/responses/*') do |name|
        body, query_string = Rack::Utils.unescape(request.body.read.to_s), request.env['QUERY_STRING']
        record = MockResponses.get_response(name, http_method, body, query_string)

        return 404 unless record
        REQUESTS[record.response_id] = body.empty? ? query_string : body

        sleep record.delay
        send_response(record, body, request, query_string)
      end
    end

    delete '/mirage/templates/:id' do
      MockResponses.delete(response_id)
      REQUESTS.delete(response_id)
      ""
    end

    delete '/mirage/requests' do
      REQUESTS.clear
      ""
    end

    delete '/mirage/requests/:id' do
      REQUESTS.delete(response_id)
      ""
    end


    delete '/mirage/templates' do
      [REQUESTS].each { |map| map.clear }
      MockResponses.clear
      MockResponse.reset_count
      ""
    end

    get '/mirage/templates/:id' do
      response = MockResponses.find(response_id)
      return 404 if response.is_a? Array
      send_response(response)
    end

    get '/mirage/requests/:id' do
      REQUESTS[response_id] || 404
    end


    get '/mirage' do
      @responses = {}

      MockResponses.all.each do |response|
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
      MockResponses.clear

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
      MockResponses.backup
      ""
    end


    put '/mirage' do
      MockResponses.revert
      ""
    end


    helpers do

      def response_id
        params[:id].to_i
      end

      def prime &block
        yield Mirage::Client.new "http://localhost:#{settings.port}/mirage"
      end

      def send_response(response, body='', request={}, query_string='')
        content_type(response.content_type)
        response.value(body, request, query_string)
      end
    end
  end
end


Mirage::Server.run! :server => 'webrick'