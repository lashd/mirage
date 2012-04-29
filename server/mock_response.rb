module Mirage
  class ServerResponseNotFound < Exception
    
  end
  class MockResponse
    class << self

      def find_by_id id
        response_set_containing(id).values.find { |response| response.response_id == id } || raise(ServerResponseNotFound)
      end

      def delete(id)
        response_set_containing(id).delete_if { |http_method, response| response.response_id == id }
      end

      def delete_all
        responses.clear
        @next_id = 0
      end

      def backup
        snapshot.clear and snapshot.replace(responses.deep_clone)
      end

      def revert
        delete_all and responses.replace(snapshot.deep_clone)
      end

      def all
        all_responses = []
        response_sets.each do |response_set|
          response_set.values.each{|response|all_responses << response}
        end
        all_responses
      end

      def find_default(body, http_method, name, query_string)
        default_response_sets = find_default_responses(name)

        until default_response_sets.empty?
          record = find_in_response_set(body, query_string, default_response_sets.delete_at(0), http_method)
          return record if record && record.default?
        end

        raise ServerResponseNotFound
      end

      def find(body, query_string, name, http_method)
        find_in_response_set(body, query_string, responses[name], http_method) || raise(ServerResponseNotFound)
      end

      def add new_response
        response_set = target_response_set(new_response)

        old_response = response_set.delete(new_response.http_method)
        response_set[new_response.http_method] = new_response
        new_response.response_id = old_response ? old_response.response_id : next_id
      end

      private

      def find_in_response_set(body, query_string, response_set, http_method)
        return unless response_set
        response_set = response_set[body] || response_set[query_string] || response_set[:basic]
        response_set[http_method.upcase] if response_set
      end

      def response_set_containing id
        response_sets.each do |response_set|
          return response_set if response_set.find { |key, response| response.response_id == id }
        end
        {}
      end

      def response_sets
        responses.values.collect { |response_sets| response_sets.values }.flatten
      end

      def find_default_responses(name)
        matches = responses.keys.find_all { |key| name.index(key) == 0 }.sort { |a, b| b.length <=> a.length }
        matches.collect { |key| responses[key] }
      end

      def target_response_set response
        responses_sets = responses[response.name]||={}
        responses_sets[response.pattern] ||= {}
      end

      def responses
        @responses ||={}
      end

      def snapshot
        @snapshot ||={}
      end

      def next_id
        @next_id||= 0
        @next_id+=1
      end

    end

    attr_reader :response_id, :delay, :name, :pattern, :http_method, :content_type
    attr_accessor :response_id

    def initialize name, value, content_type, http_method, code, pattern=nil, delay=0, default=false, file=false
      @name, @value, @content_type, @http_method, @delay, @default, @file = name, value, content_type, (http_method||'GET').upcase,  delay, default, file
      @pattern = pattern ? /#{pattern}/ : :basic
      @code = code
      MockResponse.add self
    end

    def default?
      'true' == @default
    end

    def file?
      'true' == @file
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

    def code
      @code || 200
    end

    private
    def find_match(string, regex)
      string.scan(/#{regex}/).flatten.first
    end
  end
end