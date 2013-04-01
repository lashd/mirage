require 'sinatra'
require 'helpers'
require 'base64'
module Mirage

  class Server < Sinatra::Base

    REQUESTS = {}


    helpers Mirage::Server::Helpers

    put '/mirage/templates/*' do |name|
      content_type :json
      mock_response = MockResponse.new(name, JSON.parse(request.body.read))
      mock_response.requests_url = request.url.gsub("/mirage/templates/#{name}", "/mirage/requests/#{mock_response.response_id}")
      {:id => mock_response.response_id}.to_json
    end

    %w(get post delete put).each do |http_method|
      send(http_method, '/mirage/responses/*') do |name|
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

        REQUESTS[record.response_id] = request.dup

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
      MockResponse.find_by_id(response_id).raw
    end

    get '/mirage/requests/:id' do
      content_type :json
      tracked_request = REQUESTS[response_id]
      if tracked_request

        tracked_request.body.rewind
        body = tracked_request.body.read

        parameters = tracked_request.params.dup.select{|key, value| key != body}

        { request_url: request.url,
          headers: extract_http_headers(tracked_request.env),
          parameters: parameters,
          body: body}.to_json

      else
        404
      end
    end

    get '/mirage' do
      haml :index
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
        block.call Mirage::Client.new "http://localhost:#{settings.port}/mirage"
      end

      def send_response(response, body='', request={}, query_string='')
        sleep response.response_spec['delay']
        content_type(response.response_spec['content_type'])
        status response.response_spec['status']
        response.value(body, request, query_string)
      end

      def extract_http_headers(env)
        headers = env.reject do |k, v|
          !(/^HTTP_[A-Z_]+$/ === k) || v.nil?
        end.map do |k, v|
          [reconstruct_header_name(k), v]
        end.inject(Rack::Utils::HeaderHash.new) do |hash, k_v|
          k, v = k_v
          hash[k] = v
          hash
        end

        x_forwarded_for = (headers["X-Forwarded-For"].to_s.split(/, +/) << env["REMOTE_ADDR"]).join(", ")

        headers.merge!("X-Forwarded-For" => x_forwarded_for)
      end

      def reconstruct_header_name(name)
        name.sub(/^HTTP_/, "").gsub("_", "-")
      end
    end
  end
end