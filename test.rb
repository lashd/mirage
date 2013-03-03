require 'ostruct'

struct = OpenStruct.new(:name => "leon")
struct.freeze

puts struct.name
struct.name = "hello"