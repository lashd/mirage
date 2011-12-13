module Mirage
  class MockResponses

    class << self

      def << response
        stored_responses = responses[response.name]||={}

        stored_responses[response.pattern] ||= {}
        old_response = stored_responses[response.pattern].delete(response.http_method.upcase)
        stored_responses[response.pattern][response.http_method.upcase] = response


        # Right not an the main id count goes up by one even if the id is not used because the old id is reused from another response
        response.response_id = old_response.response_id if old_response
        response.response_id.to_s
      end

      def get_response name, http_method, body, query_string
        stored_responses = responses[name]
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
          response_sets.each do |pattern, response_set|
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
  end

end