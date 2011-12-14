hash = Hash.new do |hash, key|
  hash[key] = Hash.new do |patterns_hash, pattern|
    patterns_hash[pattern] = {:blah => 'foo'}
  end
end
hash =  hash['thing']['whatever']

puts hash