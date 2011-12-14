module Mirage
  class MockResponse
    class << self

      def add response
        stored_response_sets = responses[response.name]||={}
        stored_response_set = (stored_response_sets[response.pattern] ||= {})

        old_response = stored_response_set.delete(response.http_method)
        stored_response_set[response.http_method] = response

        response.response_id = old_response ? old_response.response_id : (@@id_count+=1)
      end

      def get_response name, http_method, body, query_string

        record = find_response(body, query_string, responses[name], http_method) if responses.include?(name)

        unless record
          default_response_sets, record = find_default_responses(name), nil

          until record || default_response_sets.empty?
            record = find_response(body, query_string, default_response_sets.delete_at(0), http_method)
            if record
              record = record.default? ? record : nil
            end

          end
        end

        record
      end

      def find id
        responses.values.each do |response_sets|
          response_sets.values.each do |response_set|
            response_set.values.each do |response|
              return response if response.response_id == id
            end
          end
        end
      end

      def delete(response_id)
        responses.values.each do |response_sets|
          response_sets.values.each do |response_set|
            response_set.each do |method, response|
              response_set.delete(method) if response.response_id == response_id
            end
          end
        end
      end

      def clear
        responses.clear
      end

      def backup
        snapshot.clear and snapshot.replace(responses.deep_clone)
      end

      def revert
        responses.clear and responses.replace(snapshot.deep_clone)
      end

      def all
        all_responses = []
        responses.values.each do |response_sets|
          response_sets.values.each do |response_set|
            response_set.values.each do |response|
              all_responses << response
            end
          end
        end
        all_responses
      end

      private
      def find_response(body, query_string, stored_responses, http_method)
        http_method = http_method.upcase
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
        matches = responses.keys.find_all { |key| name.index(key) == 0 }.sort { |a, b| b.length <=> a.length }
        matches.collect { |key| responses[key] }
      end

      private
      def responses
        @responses ||={}
      end

      def snapshot
        @snapshot ||={}
      end
    end

    @@id_count = 0
    attr_reader :response_id, :delay, :name, :pattern, :http_method, :content_type
    attr_accessor :response_id

    def initialize name, value, content_type, http_method, pattern=nil, delay=0, default=false, file=false
      @name, @value,@content_type,  @http_method, @pattern, @delay, @default, @file = name, value, content_type, http_method.to_s.upcase, pattern, delay, default, file
      MockResponse.add self
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
  MockResponses = MockResponse
end
