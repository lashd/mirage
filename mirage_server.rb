require 'rubygems'
ROOT_DIR = File.dirname(__FILE__)
$LOAD_PATH.unshift("#{ROOT_DIR}/lib")
$LOAD_PATH.unshift("#{ROOT_DIR}/server")

require 'sinatra/base'

require 'extensions/object'
require 'extensions/hash'
require 'mock_response'

require 'mirage/client'

module Mirage

  class Server < Sinatra::Base

    configure do
      options = Hash[*ARGV]
      set :defaults, options["defaults"]
      set :port, options["port"]
      $0="Mirage Server port #{settings.port}"
      set :show_exceptions, false
      set :logging, true
      set :dump_errors, true
      set :server, 'webrick'
      set :views, "#{ROOT_DIR}/views"

      if options["bind"]
        set :bind, options["bind"]
      end

      log_file = File.open('mirage.log', 'a')
      log_file.sync=true
      use Rack::CommonLogger, log_file
      enable :logging
    end

    REQUESTS= {}

    put '/mirage/templates/*' do |name|
      response = request.body.read

      MockResponse.new(name,
                       response,
                       :content_type => @env['CONTENT_TYPE'],
                       :http_method => @env['HTTP_X_MIRAGE_METHOD'],
                       :status => @env['HTTP_X_MIRAGE_STATUS'],
                       :pattern => @env['HTTP_X_MIRAGE_PATTERN'],
                       :delay => @env['HTTP_X_MIRAGE_DELAY'].to_f,
                       :default => @env['HTTP_X_MIRAGE_DEFAULT'],
                       :file => @env['HTTP_X_MIRAGE_FILE']).response_id.to_s
    end

    ['get', 'post', 'delete', 'put'].each do |http_method|
      send(http_method, '/mirage/responses/*') do |name|
        body, query_string = Rack::Utils.unescape(request.body.read.to_s), request.query_string

        begin
          record = MockResponse.find(body, query_string, name, http_method)
        rescue ServerResponseNotFound
          record = MockResponse.find_default(body, http_method, name, query_string)
        end

        REQUESTS[record.response_id] = body.empty? ? query_string : body

        send_response(record, body, request, query_string)
      end
    end

    delete '/mirage/templates/:id' do
      MockResponse.delete(response_id)
      REQUESTS.delete(response_id)
      200
    end

    delete '/mirage/requests' do
      REQUESTS.clear
      200
    end

    delete '/mirage/requests/:id' do
      REQUESTS.delete(response_id)
      200
    end

    delete '/mirage/templates' do
      REQUESTS.clear
      MockResponse.delete_all
      200
    end

    get '/mirage/templates/:id' do
      send_response(MockResponse.find_by_id(response_id))
    end

    get '/mirage/requests/:id' do
      REQUESTS[response_id] || 404
    end

    get '/mirage' do
      @responses = {}

      MockResponse.all.each do |response|
        pattern = response.pattern.is_a?(Regexp) ? "pattern = #{response.pattern.source}" : ''
        delay = response.delay > 0 ? "delay = #{response.delay}" : ''
        pattern << ' ,' unless pattern.empty? || delay.empty?
        @responses["#{response.name}#{'/*' if response.default?}: #{pattern} #{delay}"] = response
      end
      erb :index
    end


    put '/mirage/defaults' do
      MockResponse.delete_all
      if File.directory?(settings.defaults.to_s)
        Dir["#{settings.defaults}/**/*.rb"].each do |default|
          begin
            eval File.read(default)
          rescue Exception => e
            raise "Unable to load default responses from: #{default}"
          end
        end
      end
      200
    end
#
    put '/mirage/backup' do
      MockResponse.backup
      200
    end


    put '/mirage' do
      MockResponse.revert
      200
    end

    get '/mirage/pid' do
      "#{$$}"
    end

    error ServerResponseNotFound do
      404
    end

    error do
      erb request.env['sinatra.error'].message
    end

    helpers do

      def response_id
        params[:id].to_i
      end

      def prime &block
        yield Mirage::Client.new "http://localhost:#{settings.port}/mirage"
      end

      def send_response(response, body='', request={}, query_string='')
        sleep response.delay
        content_type(response.content_type)
        status response.status
        response.value(body, request, query_string)
      end
    end
  end
end


Mirage::Server.run! :server => 'webrick'
