require 'ramaze'
require 'ramaze/helper/send_file'

class Object
  def deep_clone
    Marshal.load(Marshal.dump(self))
  end
end

module Mirage

  class MockResponse
    @@id_count = 0
    attr_reader :response_id, :delay, :name, :pattern
    attr_accessor :response_id

    def initialize name, value, pattern=nil, delay=0, root_response=false
      @name, @value, @pattern, @response_id, @delay, @root_response = name, value, pattern, @@id_count+=1, delay, root_response
    end

    def self.reset_count
      @@id_count = 0
    end

    def root_response?
      @root_response
    end

    def file?
      !@value.is_a?(String)
    end


    def value(body='', request_parameters={}, query_string='')
      return @value if file?

      value = @value
      value.scan(/\$\{(.*)?\}/).flatten.each do |pattern|

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


  class MirageServer < Ramaze::Controller
    include Ramaze::Helper::SendFile
    map '/mirage'
    RESPONSES, REQUESTS, SNAPSHOT= {}, {}, {}

    def index
      @responses = {}

      RESPONSES.each do |name, responses|
        @responses[name]=responses.default unless responses.default.nil?

        responses.each do |pattern, response|
          @responses["#{name}: #{pattern}"] = response
        end
      end
    end

    def peek response_id
      peeked_response = nil
      RESPONSES.values.each do |responses|
        peeked_response = responses[:default] if responses[:default] && responses[:default].response_id == response_id.to_i
        peeked_response = responses.values.find { |response| response.response_id == response_id.to_i } if peeked_response.nil?
        break unless peeked_response.nil?
      end
      respond("Can not peek reponse, id:#{response_id} does not exist}", 404) unless peeked_response
      send_response(peeked_response)
    end

    def set *args
      delay = (request['delay']||0)
      pattern = request['pattern'] ? /#{request['pattern']}/ : :default
      name = args.join('/')
      is_root_response = request['root_response'] == 'true'

      response = MockResponse.new(name, (request[:file]||response_value), pattern, delay.to_f, is_root_response)

      stored_responses = RESPONSES[name]||={}

      old_response = stored_responses[pattern]
      stored_responses[pattern] = response

      # Right not an the main id count goes up by one even if the id is not used because the old id is reused from another response
      response.response_id = old_response.response_id if old_response
      response.response_id
    end

    def find_response(body, query_string, stored_responses)
      pattern_match = stored_responses.keys.find_all { |pattern| pattern != :default }.find { |pattern| body =~ pattern || query_string =~ pattern }
      record = pattern_match ? stored_responses[pattern_match] : stored_responses[:default]
      record
    end

    def get *args
      body, query_string = Rack::Utils.unescape(request.body.read.to_s), request.env['QUERY_STRING']
      requires_root_response, name = false, args.join('/')
      stored_responses = RESPONSES[name]

      if stored_responses
        record = find_response(body, query_string, stored_responses)
      else
        requires_root_response = true
        record = nil
        stored_responses = root_response(name).deep_clone || {}

        until (record && record.root_response?) || stored_responses.empty?
          record = find_response(body, query_string, stored_responses.delete_at(0))
        end
      end

      respond('Response not found', 404) if record.nil? || (requires_root_response && !record.root_response?)

      sleep record.delay
      REQUESTS[record.response_id] = body.empty? ? query_string : body

      send_response(record, body, request, query_string)
    end

    def clear datatype=nil, response_id=nil
      response_id = response_id.to_i
      case datatype
        when 'requests' then
          REQUESTS.clear
        when 'responses' then
          RESPONSES.clear and REQUESTS.clear and MockResponse.reset_count
        when /\d+/ then
          delete_response(datatype.to_i)
        when 'request'
          REQUESTS.delete(response_id)
        when nil
          [REQUESTS, RESPONSES].each { |map| map.clear }
          MockResponse.reset_count
      end
    end

    def query id
      REQUESTS[id.to_i] || respond("Nothing stored for: #{id}", 404)
    end

    def snapshot
      SNAPSHOT.clear and SNAPSHOT.replace(RESPONSES.deep_clone)
    end

    def rollback
      RESPONSES.clear and RESPONSES.replace(SNAPSHOT.deep_clone)
    end

    def load_defaults
      clear
      Dir["#{DEFAULT_RESPONSES_DIR}/**/*.rb"].each do |default|
        begin
          load default
        rescue Exception
          respond("Unable to load default responses from: #{default}", 500)
        end

      end
    end

    private
    def response_value
      return request['response'] unless request['response'].nil?
      respond('response or file parameter required', 500)
    end

    def root_response(name)
      matches = RESPONSES.keys.find_all { |key| name.index(key) == 0 }.sort { |a, b| b.length <=> a.length }
      matches.collect { |key| RESPONSES[key] }
    end

    def delete_response(response_id)
      RESPONSES.each do |name, response_set|
        response_set.each { |key, response| response_set.delete(key) if response.response_id == response_id }
      end
      REQUESTS.delete(response_id)
    end

    def send_response(response, body='', request={}, query_string='')
      if response.file?
        tempfile, filename, type = response.value.values_at(:tempfile, :filename, :type)
        send_file(tempfile.path, type, "Content-Disposition: attachment; filename=#{filename}")
      else
        response.value(body, request, query_string)
      end
    end

  end
end