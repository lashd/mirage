class Thing
  include Enumerable

  def each &block
    all().each &block
  end

  def all
    [1, 2, 3]
  end

  def [] num
    all[num]
  end
end

thing = Thing.new
thing.each do |thing|
  puts thing
end

puts thing[1]