require "#{::File.expand_path("#{::File.dirname(__FILE__)}/mockserver")}"
Ramaze.start(:root => __DIR__, :started => true)
run Ramaze

