require "#{::File.expand_path("#{::File.dirname(__FILE__)}/mockserver_core")}"
Ramaze.start(:root => __DIR__, :started => true)
run Ramaze

