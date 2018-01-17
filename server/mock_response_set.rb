module Mirage
  class MockResponseSet < Hash
    def fuzzy_find desired_key, http_method
      result = self[desired_key]
      return result unless result.nil?
      result = find_all do |key, value|
        key.is_a?(Regexp) && desired_key.is_a?(String) && key.match(desired_key) && value[http_method.upcase]
      end.sort do |a,b|
        b.first.source.size <=> a.first.source.size
      end
      result.first && result.first[1]
    end
  end
end
