require 'sinatra/base'
require 'sinatra/reloader'
require 'json'
class Object
  def deep_clone
    Marshal.load(Marshal.dump(self))
  end
end


module Mirage


  class MirageServer < Sinatra::Base


    class MockResponse
      @@id_count = 0
      attr_reader :response_id, :delay, :name, :pattern,:http_method
      attr_accessor :response_id

      def initialize name, value, http_method, pattern=nil, delay=0, default=false
        @name, @value, @http_method, @pattern, @response_id, @delay, @default = name, value, http_method, pattern, @@id_count+=1, delay, default
      end

      def self.reset_count
        @@id_count = 0
      end

      def default?
        'true' == @default
      end

      def file?
        !@value.is_a?(String)
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

    RESPONSES, REQUESTS, SNAPSHOT= {}, {}, {}

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

    put %r{/mirage/responses/((?!replay).)*$} do
      name = request.route.gsub('/mirage/responses/','')
#      [^']*
      response = JSON.parse(request.body.read)
      http_method = response['method'] || 'GET'

      pattern = response['pattern'] ? /#{response['pattern']}/ : :basic

      response = MockResponse.new(name, response['response'], http_method, pattern, response['delay'].to_f, response['default'])

      stored_responses = RESPONSES[name]||={}
      
      stored_responses[pattern] ||= {}
      old_response = stored_responses[pattern].delete(http_method)
      stored_responses[pattern][http_method] = response 
      

      # Right not an the main id count goes up by one even if the id is not used because the old id is reused from another response
      response.response_id = old_response.response_id if old_response
      response.response_id.to_s
    end

    [ 'get', 'post', 'delete', 'put'].each do |http_method|
      send(http_method, '/mirage/responses/*.replay') do |name|
        get_response(name, http_method.upcase)
      end
    end
    
    delete '/mirage/responses' do
      [REQUESTS, RESPONSES].each { |map| map.clear }
      MockResponse.reset_count
    end


#    get '/mirage' do
#      @responses = {}
#
#      RESPONSES.each do |name, responses|
#        responses.each do |pattern, response|
#          pattern = pattern.is_a?(Regexp) ? "pattern = #{pattern.source}" : ''
#          delay = response.delay > 0 ? "delay = #{response.delay}" : ''
#          pattern << ' ,' unless pattern.empty? || delay.empty?
#          @responses["#{name}#{'/*' if response.default?}: #{pattern} #{delay}"] = response
#        end
#      end
#      erb :index
#    end

#    get '/mirage/*' do |name|
#      get_response(name)
#    end
#
#    post '/mirage/*' do |name|
#      get_response(name)
#    end

    error do
      erb request.env['sinatra.error'].message
    end

#    post '/mirage/prime' do
#      [REQUESTS, RESPONSES].each { |map| map.clear }
#
#      Dir["#{DEFAULT_RESPONSES_DIR}/**/*.rb"].each do |default|
#        begin
#          load default
#        rescue Exception
#          raise "Unable to load default responses from: #{default}"
#        end
#
#      end
#    end


#    get '/mirage/peek/:response_id' do
#      peeked_response = nil
#      response_id = params['response_id']
#      RESPONSES.values.each do |responses|
#        peeked_response = responses.values.find { |response| response.response_id == response_id.to_i }
#        break unless peeked_response.nil?
#      end
#      return 404 unless peeked_response
#      send_response(peeked_response)
#    end
#
#    put '/mirage/*' do |name|
#      response = JSON.parse(request.body.read)
#
#      pattern = response['pattern'] ? /#{response['pattern']}/ : :basic
#
#      response = MockResponse.new(name, response['response'], pattern, response['delay'].to_f, response['default'])
#
#      stored_responses = RESPONSES[name]||={}
#
#      old_response = stored_responses.delete(pattern)
#      stored_responses[pattern] = response
#
#      # Right not an the main id count goes up by one even if the id is not used because the old id is reused from another response
#      response.response_id = old_response.response_id if old_response
#      response.response_id.to_s
#    end
#    
#    get '/mirage/clear/*' do
#      datatype, response_id = params[:splat][0], params[:splat][1].to_i
#      puts "datatype is: #{datatype}"
#      clear(datatype, response_id)
#    end
#
#    get '/mirage/clear' do
#      clear
#    end
#
#    get '/mirage/track/:id' do
#      id = params[:id]
#      REQUESTS[id.to_i] || 404
#    end
#
#    post '/mirage/save' do
#      SNAPSHOT.clear and SNAPSHOT.replace(RESPONSES.deep_clone)
#    end
#
#    post '/mirage/revert' do
#      RESPONSES.clear and RESPONSES.replace(SNAPSHOT.deep_clone)
#    end


    def set_response name
      delay = (request['delay']||0)
      pattern = request['pattern'] ? /#{request['pattern']}/ : :basic
      is_default = request['default'] == 'true'

#      response_value =  request['response'] unless request['response'].nil?
      value = response_value
      if value.nil?
        return 500
      end

      response = MockResponse.new(name, value, pattern, delay.to_f, is_default)

      stored_responses = RESPONSES[name]||={}

      old_response = stored_responses.delete(pattern)
      stored_responses[pattern] = response

      # Right not an the main id count goes up by one even if the id is not used because the old id is reused from another response
      response.response_id = old_response.response_id if old_response
      response.response_id.to_s

    end


    def get_response name, http_method
       body, query_string = Rack::Utils.unescape(request.body.read.to_s), request.env['QUERY_STRING']
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

      return 404 unless record
      REQUESTS[record.response_id] = body.empty? ? query_string : body

      sleep record.delay
      send_response(record, body, request, query_string)
    end


    def clear(datatype=nil, response_id=nil)
      case datatype
        when 'requests' then
          REQUESTS.clear
        when 'responses' then
          RESPONSES.clear and REQUESTS.clear and MockResponse.reset_count
        when /\d+/ then
          response_id = datatype.to_i
          delete_response(response_id)
          REQUESTS.delete(response_id)
        when 'request'
          REQUESTS.delete(response_id)
        when nil || ''
          [REQUESTS, RESPONSES].each { |map| map.clear }
          MockResponse.reset_count
      end
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
#      record = pattern_match ? stored_responses[pattern_match] : stored_responses[:basic]
      record
    end

    def response_value
      return request['response'] unless request['response'].nil?
    end

    def find_default_responses(name)
      matches = RESPONSES.keys.find_all { |key| name.index(key) == 0 }.sort { |a, b| b.length <=> a.length }
      matches.collect { |key| RESPONSES[key] }
    end

    def delete_response(response_id)
      RESPONSES.values.each do |response_set|
        response_set.each { |key, response| response_set.delete(key) if response.response_id == response_id }
      end
    end

    def send_response(response, body='', request={}, query_string='')
      if response.file?
        tempfile, filename, type = response.value.values_at(:tempfile, :filename, :type)
        tempfile.binmode
        send_file(tempfile.path, :type => type)
      else
        response.value(body, request, query_string)
      end
    end
  end
end