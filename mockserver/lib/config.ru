require 'rubygems'
require 'bundler/setup'
Bundler.setup(:default)
require "#{::File.expand_path("#{::File.dirname(__FILE__)}/mirage/mockserver_core")}"
Ramaze.start(:root => __DIR__, :started => true)
run Ramaze

