require 'binary_data_checker'

require 'hashie/mash'
require 'mock_response_set'


module Mirage
  class ServerResponseNotFound < Exception

  end

  class MalformedResponse < Exception

  end

  class MockResponse
    class << self

      def find_by_id(id)
        all.find { |response| response.response_id == id } || raise(ServerResponseNotFound)
      end

      def delete(id)
        responses.values.each do |set|
          set.values.each { |responses| responses.delete_if { |response| response.response_id == id } }
        end
      end

      def delete_all
        responses.clear
        @next_id = 0
      end

      #TODO - this is flakey, make a proper copy
      def backup
        snapshot.clear and snapshot.replace(responses.deep_clone)
      end

      def revert
        delete_all and responses.replace(snapshot.deep_clone)
      end

      def all
        responses.values.collect do |response_set|
          response_set.values
        end.flatten
      end

      def find_default(options)
        options[:http_method].upcase!
        http_method = options[:http_method]
        default_responses = subdomains(options[:endpoint]).collect do |domain|
          if (responses_for_domain = responses.fuzzy_find(domain))
            responses_for_domain[http_method].find_all { |response| response.default? } if responses_for_domain[http_method]
          end
        end.flatten.compact

        default_responses.find { |response| match?(options, response) } || raise(ServerResponseNotFound)
      end

      def subdomains(name)
        domains=[]
        name.split("/").each do |part|
          domains << (domains.last ? "#{domains.last}/#{part}" : part)
        end
        domains.reverse
      end

      def find(options)
        options[:response_set] = responses.fuzzy_find(options[:endpoint])
        find_in_response_set(options) || raise(ServerResponseNotFound)
      end

      def add(new_response)
        response_set = responses_for_endpoint(new_response)
        method_specific_responses = response_set[new_response.request_spec['http_method'].upcase]||=[]
        duplicate_response_location = method_specific_responses.index { |response| response.request_spec == new_response.request_spec }
        old_response = method_specific_responses.delete_at(duplicate_response_location) if duplicate_response_location
        if old_response
          new_response.response_id = old_response.response_id
        else
          new_response.response_id = next_id
        end
        method_specific_responses<<new_response
      end

      private
      def find_in_response_set(options)
        response_set = options.delete(:response_set)
        return unless response_set

        responses_for_http_method = response_set[options[:http_method].upcase] || []

        responses = responses_for_http_method.find_all do |stored_response|
          match?(options, stored_response)
        end

        responses.sort { |a, b| b.score <=> a.score }.first

      end

      def match?(options, stored_response)
        parameters = options[:params]
        headers = Hash[options[:headers].collect { |key, value| [key.downcase, value] }]

        request_spec = stored_response.request_spec

        match = true

        {request_spec['parameters'] => parameters,
         request_spec['headers'] => headers}.each do |spec, actual|
          spec.each do |key, value|
            value = interpret_value(value)
            if value.is_a? Regexp
              match = false unless value.match(actual[key])
            else
              match = false unless value == actual[key]
            end
          end
        end

        request_spec['body_content'].each do |value|
          value = interpret_value(value)
          if value.is_a? Regexp
            match = false unless options[:body] =~ value
          else
            match = false unless options[:body].include?(value)
          end
        end

        match
      end

      def interpret_value(value)
        value.start_with?("%r{") && value.end_with?("}") ? eval(value) : value
      end

      def responses_for_endpoint(response)
        name = response.name
        name = %r{#{name.gsub('*', '.*')}} if name =~ /\*/
        responses[name]||={}
      end

      def responses
        @responses ||= MockResponseSet.new
      end

      def snapshot
        @snapshot ||={}
      end

      def next_id
        @next_id||= 0
        @next_id+=1
      end
    end

    attr_reader :name, :request_spec, :response_spec
    attr_accessor :response_id, :requests_url

    def initialize name, spec={}

      request_defaults = JSON.parse({:parameters => {},
                                     :body_content => [],
                                     :http_method => 'get',
                                     :headers => {}}.to_json)
      response_defaults = JSON.parse({:default => false,
                                      :body => Base64.encode64(''),
                                      :delay => 0,
                                      :content_type => "text/plain",
                                      :status => 200}.to_json)

      @name = name
      @spec = spec

      @request_spec = Hashie::Mash.new request_defaults.merge(spec['request']||{})
      @response_spec = Hashie::Mash.new response_defaults.merge(spec['response']||{})

      @request_spec['headers'] = Hash[@request_spec['headers'].collect { |key, value| [key.downcase, value.to_s] }]
      @request_spec['parameters'] = Hash[@request_spec['parameters'].collect { |key, value| [key, value.to_s] }]
      @request_spec['body_content'] = @request_spec['body_content'].collect { |value| value.to_s }
      @binary = BinaryDataChecker.contains_binary_data? @response_spec['body']

      MockResponse.add self
    end

    def headers
      @response_spec['headers']
    end

    def default?
      @response_spec["default"]
    end

    def score
      [@request_spec['headers'].values, @request_spec['parameters'].values, @request_spec['body_content']].inject(0) do |score, matchers|
        matchers.inject(score) { |matcher_score, value| interpret_value(value).is_a?(Regexp) ? matcher_score+=1 : matcher_score+=2 }
      end
    end

    def value(request_body='', request_parameters={}, query_string='')
      body = Base64.decode64(response_spec['body'])
      return body if @binary

      value = body.dup
      value.scan(/\$\{([^\}]*)\}/).flatten.each do |pattern|

        if (parameter_match = request_parameters[pattern])
          value = value.gsub("${#{pattern}}", parameter_match)
        end

        [request_body, query_string].each do |string|
          if (string_match = find_match(string, pattern))
            value = value.gsub("${#{pattern}}", string_match)
          end
        end

      end
      value
    end

    def == response
      response.is_a?(MockResponse) && @name == response.send(:eval, "@name") && @request_spec == response.send(:eval, "@request_spec") && @response_spec == response.send(:eval, "@response_spec")
    end

    def raw
      {:id => response_id, :endpoint => @name, :requests_url => requests_url, :response => @response_spec, :request => @request_spec}.to_json
    end

    def binary?
      @binary
    end

    private
    def find_match(string, regex)
      string.scan(/#{regex}/).flatten.first
    end

    def interpret_value(value)
      value.start_with?("%r{") && value.end_with?("}") ? eval(value) : value
    end


  end
end