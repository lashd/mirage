require 'rubygems'
require 'win32/process'
fork do
  `start "mirage server" ruby #{File.dirname(__FILE__)}/start_mirage.rb #{ARGV.join(' ')}`
end