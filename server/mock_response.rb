module Mirage
  class MockResponse
    class << self

      def add response
        stored_responses = responses[response.name]||={}

        stored_responses[response.pattern] ||= {}
        old_response = stored_responses[response.pattern].delete(response.http_method.upcase)
        stored_responses[response.pattern][response.http_method.upcase] = response


        # Right now an the main id count goes up by one even if the id is not used because the old id is reused from another response
        response.response_id = old_response.response_id if old_response
        response.response_id.to_s
      end

      def get_response name, http_method, body, query_string
        stored_responses = responses[name]

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
      @name, @value,@content_type,  @http_method, @pattern, @response_id, @delay, @default, @file = name, value, content_type, http_method, pattern, @@id_count+=1, delay, default, file
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
