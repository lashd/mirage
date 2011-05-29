require 'sinatra/base'
require 'sinatra/reloader'
class Object
  def deep_clone
    Marshal.load(Marshal.dump(self))
  end
end


module Mirage
  class MockResponse
    @@id_count = 0
    attr_reader :response_id, :delay, :name, :pattern, :http_method, :content_type
    attr_accessor :response_id

    def initialize name, value, content_type, http_method, pattern=nil, delay=0, default=false, file=false
      @name, @value,@content_type,  @http_method, @pattern, @response_id, @delay, @default, @file = name, value, content_type, http_method, pattern, @@id_count+=1, delay, default, file
    end

    def self.reset_count
      @@id_count = 0
    end

    def default?
      'true' == @default
    end

    def file?
      @file == 'true'
    end


    def value(body='', request_parameters={}, query_string='')
      return @value if file?

      value = @value
      value.scan(/\$\{([^\}]*)\}/).flatten.each do |pattern|

        if (parameter_match = request_parameters[pattern])
          value = value.gsub("${#{pattern}}", parameter_match)
        end

        [body, query_string].each do |string|
          if (string_match = find_match(string, pattern))
            value = value.gsub("${#{pattern}}", string_match)
          end
        end

      end
      value
    end

    private
    def find_match(string, regex)
      string.scan(/#{regex}/).flatten.first
    end
  end

  class MockResponsesCollection
    SNAPSHOT, RESPONSES = {}, {}

    def << response


      stored_responses = RESPONSES[response.name]||={}

      stored_responses[response.pattern] ||= {}
      old_response = stored_responses[response.pattern].delete(response.http_method)
      stored_responses[response.pattern][response.http_method] = response


      # Right not an the main id count goes up by one even if the id is not used because the old id is reused from another response
      response.response_id = old_response.response_id if old_response
      response.response_id.to_s

    end

    def get_response name, http_method, body, query_string
      stored_responses = RESPONSES[name]
      record = nil

      record = find_response(body, query_string, stored_responses, http_method) if stored_responses


      unless record
        default_responses, record = find_default_responses(name), nil

        until record || default_responses.empty?
          record = find_response(body, query_string, default_responses.delete_at(0), http_method)
          if record
            record = record.default? ? record : nil
          end

        end
      end

      record
    end

    def find id
      RESPONSES.values.each do |response_sets|
        response_sets.values.each do |response_set|
          response_set.values.each do |response|
            return response if response.response_id == id
          end
        end
      end
    end

    def delete(response_id)
      RESPONSES.values.each do |response_sets|
        response_sets.values.each do |response_set|
          response_set.each do |method, response|
            response_set.delete(method) if response.response_id == response_id
          end
        end
      end
    end

    def clear
      RESPONSES.clear
    end

    def backup
      SNAPSHOT.clear and SNAPSHOT.replace(RESPONSES.deep_clone)
    end

    def revert
      RESPONSES.clear and RESPONSES.replace(SNAPSHOT.deep_clone)
    end

    def all
      responses = []
      RESPONSES.values.each do |response_sets|
        response_sets.each do |pattern, response_set|
          response_set.values.each do |response|
            responses << response
          end
        end
      end
      responses
    end

    private
    def find_response(body, query_string, stored_responses, http_method)
      pattern_match = stored_responses.keys.find_all { |pattern| pattern != :basic }.find { |pattern| (body =~ pattern || query_string =~ pattern) }

      if pattern_match
        record = stored_responses[pattern_match][http_method]
      else
        record = stored_responses[:basic]
        record = record[http_method] if record
      end
      record
    end

    def find_default_responses(name)
      matches = RESPONSES.keys.find_all { |key| name.index(key) == 0 }.sort { |a, b| b.length <=> a.length }
      matches.collect { |key| RESPONSES[key] }
    end

  end


  class MirageServer < Sinatra::Base

    REQUESTS, SNAPSHOT= {}, {}

    MOCK_RESPONSES = MockResponsesCollection.new

    configure do
      require 'logger'
      enable :logging
      log_file = File.open('mirage.log', 'a')
      log_file.sync=true
      use Rack::CommonLogger, log_file
      register Sinatra::Reloader
      also_reload "**/*.rb"
    end

    set :views, File.dirname(__FILE__) + '/../views'

    put '/mirage/templates/*' do |name|
      response = request.body.read

      headers = request.env
      http_method = headers['HTTP_X_MIRAGE_METHOD'] || 'GET'

      pattern = headers['HTTP_X_MIRAGE_PATTERN'] ? /#{headers['HTTP_X_MIRAGE_PATTERN']}/ : :basic
#
      MOCK_RESPONSES << MockResponse.new(name, response,headers['CONTENT_TYPE'], http_method ,pattern, headers['HTTP_X_MIRAGE_DELAY'].to_f, headers['HTTP_X_MIRAGE_DEFAULT'], headers['HTTP_X_MIRAGE_FILE'])
    end

    ['get', 'post', 'delete', 'put'].each do |http_method|
      send(http_method, '/mirage/responses/*') do |name|
        body, query_string = Rack::Utils.unescape(request.body.read.to_s), request.env['QUERY_STRING']
        record = MOCK_RESPONSES.get_response(name, http_method.upcase, body, query_string)

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

      Dir["#{DEFAULT_RESPONSES_DIR}/**/*.rb"].each do |default|
        begin
          load default
        rescue Exception
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