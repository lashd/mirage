require 'rubygems'
require "#{::File.expand_path("#{::File.dirname(__FILE__)}/mirage/core")}"
Ramaze.start(:root => __DIR__, :started => true)
run Ramaze

