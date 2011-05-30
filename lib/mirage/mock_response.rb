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
end