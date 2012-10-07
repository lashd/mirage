module Mirage
  class ServerResponseNotFound < Exception

  end
  class MockResponse
    class << self

      def find_by_id id
        all.find{|response| response.response_id == id} || raise(ServerResponseNotFound)
      end

      def delete(id)
        responses.values.each do |set|
          set.values.each{|responses| responses.delete_if{|response|response.response_id == id}}
        end
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
        responses.values.collect do|response_set|
          response_set.values
        end.flatten
      end

      def find_default(body, http_method, name, query_string)
        http_method.upcase!
        default_responses = subdomains(name).collect do |domain|
          if(responses_for_domain = responses[domain])
            responses_for_domain[http_method].find_all{|response| response.default?} if responses_for_domain[http_method]
          end
        end.flatten.compact

        default_responses.find{|response| match?(body, query_string, response)} || raise(ServerResponseNotFound)
      end

      def subdomains(name)
        domains=[]
        name.split("/").each do |part|
          domains << (domains.last ? "#{domains.last}/#{part}" : part)
        end
        domains.reverse
      end

      def find(body, query_string, name, http_method)
        find_in_response_set(body, query_string, responses[name], http_method) || raise(ServerResponseNotFound)
      end

      def add new_response
        response_set = responses_for_endpoint(new_response)
        method_specific_responses = response_set[new_response.http_method]||=[]
        old_response = method_specific_responses.delete_at(method_specific_responses.index(new_response)) if method_specific_responses.index(new_response)
        if old_response
          new_response.response_id = old_response.response_id
        else
          new_response.response_id = next_id
        end
        method_specific_responses<<new_response
      end

      private
      def find_in_response_set(body, query_string, response_set, http_method)
        return unless response_set

        responses_for_http_method = response_set[http_method.upcase] || []

        responses = responses_for_http_method.find_all do |stored_response|
          match?(body, query_string, stored_response)
        end

        responses.sort{|a, b| b.score <=> a.score}.first

      end

      def match?(body, query_string, stored_response)
        match = true
        stored_response.options[:required_parameters].each do |key, value|
          if value.is_a? Regexp
            match = false unless value.match(query_string[key])
          else
            match = false unless value == query_string[key]
          end
        end

        stored_response.options[:required_body_content].each do |value|
          if value.is_a? Regexp
            match = false unless body =~ value
          else
            match = false unless body.include?(value)
          end

        end

        match
      end

      def responses_for_endpoint response
        responses[response.name]||={}
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

    attr_reader :name, :options
    attr_accessor :response_id

    def initialize name, value, options={}
      @name, @value = name, value
      @options = {:http_method => 'GET', :delay => 0.0, :status => 200, :required_parameters => {}, :required_body_content => {}}.merge(options) { |key, old_value, new_value| new_value || old_value }
      @options[:http_method].upcase!
      MockResponse.add self
    end

    def method_missing *args
      @options[args.first.to_s.to_sym]
    end

    def default?
      @options[:default].to_s.downcase == "true"
    end

    def score
      [@options[:required_parameters].values, @options[:required_body_content]].inject(0) do |score, matchers|
        matchers.inject(score){|matcher_score, value| value.is_a?(Regexp) ? matcher_score+=1 : matcher_score+=2}
      end
    end

    def value(body='', request_parameters={}, query_string='')
      return @value if binary

      value = @value.dup
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

    def == response
      response.is_a?(MockResponse) && @name == response.send(:eval, "@name") && @options == response.send(:eval, "@options")
    end

    private
    def find_match(string, regex)
      string.scan(/#{regex}/).flatten.first
    end
  end
end