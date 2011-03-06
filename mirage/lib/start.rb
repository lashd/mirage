#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
Bundler.setup
$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../lib")
require 'mirage/core'

options = {:port => 7001}

OptionParser.new(ARGV) do |opts|
  opts.on("-p", "--port PORT", "the port to start Mirage on") do |port|
    puts "options are #{port}"
    options[:port] = port
  end
end.parse!

Ramaze.start :port => options[:port]
