module Mirage
  class MockResponseSet < Hash
    def fuzzy_find desired_key, http_method
      http_method = http_method.upcase
      result = self[desired_key]

      results = find_all do |key, value|
        key.is_a?(Regexp) && desired_key.is_a?(String) && key.match(desired_key) && value[http_method]
      end.sort do |a, b|
        b.first.source.size <=> a.first.source.size
      end

      return result unless results && results.first

      return results.first[1] unless result && result[http_method]

      {http_method => result[http_method].concat(results.first[1][http_method])}
    end
  end
end
