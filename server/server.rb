require 'sinatra'
require 'helpers'
require 'base64'
module Mirage

  class Server < Sinatra::Base

    REQUESTS = {}

    helpers Helpers::TemplateRequirements, Helpers::HttpHeaders

    put '/templates/*' do |name|
      content_type :json
      mock_response = synchronize do
        MockResponse.new(name, JSON.parse(request.body.read))
      end

      mock_response.requests_url = request.url.gsub("/templates/#{name}", "/requests/#{mock_response.response_id}")
      {:id => mock_response.response_id}.to_json
    end

    %w(get post delete put options).each do |http_method|
      send(http_method, '/responses/*') do |name|
        body, query_string = Rack::Utils.unescape(request.body.read.to_s), request.query_string

          options = {:body => body,
                   :http_method => http_method,
                   :endpoint => name,
                   :params => request.params,
                   :headers => extract_http_headers(env)}
        begin
          record = MockResponse.find(options)
        rescue ServerResponseNotFound
          record = MockResponse.find_default(options)
        end

        synchronize do
          REQUESTS[record.response_id] = request.dup
        end


        send_response(record, body, request, query_string)
      end
    end

    get '/templates/:id/preview' do
      send_response(MockResponse.find_by_id(response_id), '', {}, '')
    end

    delete '/templates/:id' do
      synchronize do
        MockResponse.delete(response_id)
        REQUESTS.delete(response_id)
      end

      200
    end

    delete '/requests' do
      synchronize do
        REQUESTS.clear
      end

      200
    end

    delete '/requests/:id' do
      synchronize do
        REQUESTS.delete(response_id)
      end

      200
    end

    delete '/templates' do
      synchronize do
        REQUESTS.clear
        MockResponse.delete_all
      end

      200
    end

    get '/templates/:id' do
      MockResponse.find_by_id(response_id).raw
    end

    get '/requests/:id' do
      content_type :json
      tracked_request = REQUESTS[response_id]
      if tracked_request

        tracked_request.body.rewind
        body = tracked_request.body.read

        parameters = tracked_request.params.dup.select { |key, value| key != body }

        {id: request.url,
         request_url: tracked_request.url,
         headers: extract_http_headers(tracked_request.env),
         parameters: parameters,
         body: body}.to_json

      else
        404
      end
    end

    get '/' do
      haml :index
    end


    put '/defaults' do
      synchronize do
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
      end
      200
    end
#
    put '/backup' do
      synchronize do
        MockResponse.backup
      end

      200
    end


    put '/' do
      synchronize do
        MockResponse.revert
      end

      200
    end

    get '/pid' do
      "#{$$}"
    end

    error ServerResponseNotFound do
      404
    end

    error do
      erb request.env['sinatra.error'].message
    end

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


    end
  end
end