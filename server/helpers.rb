module Mirage
  class Server < Sinatra::Base
    module Helpers
      def convert_raw_required_params raw_requirements
        raw_requirements.collect { |requirement| requirement.split(":") }.inject({}) do |hash, pair|
          parameter, value = pair.collect { |string| string.strip }
          value = convert_value(value)
          hash[parameter] =value; hash
        end
      end

      def convert_raw_required_body_content_requirements raw_requirements
        raw_requirements.collect do |string|
          string.start_with?("%r{") && string.end_with?("}") ? eval(string) : string
        end
      end

      private
      def convert_value(value)
        value.start_with?("%r{") && value.end_with?("}") ? eval(value) : value
      end
    end
  end
end