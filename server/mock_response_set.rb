module Mirage
  class MockResponseSet < Hash
    def fuzzy_find desired_key
      result = self[desired_key]
      return result unless result.nil?
      key, value = find{|key, value| key.is_a?(Regexp) && desired_key.is_a?(String) && key.match(desired_key) }
      value
    end
  end
end
