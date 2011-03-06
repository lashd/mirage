#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../lib")
require 'mirage/core'
require 'mirage/util'
include Mirage::Util

Ramaze.start parse_options(ARGV)
