$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../../lib")
require 'rubygems'
require 'mirage'
require 'cucumber'
require 'rspec'
require 'mechanize'

SCRATCH = './scratch'
RUBY_CMD = RUBY_PLATFORM == 'JAVA' ? 'jruby' : 'ruby'
$log_file_marker = 0


module CommandLine
  def execute command
    command_line_output_path = "#{SCRATCH}/commandline_output.txt"
    system "export RUBYOPT='' && cd #{SCRATCH} && #{command} > #{File.basename(command_line_output_path)}"
    File.read(command_line_output_path)
  end
end


module Web
  include Mirage::Web

  def get(url)
    browser = Mechanize.new
    browser.keep_alive= false
    browser.get(url)
  end

  def hit_mirage(url, parameters={})
    start_time = Time.now
    file = parameters.values.find { |value| value.is_a?(File) }
    response = (file ? http_post(url, parameters) : http_get(url, parameters))
    @response_time = Time.now - start_time
    response
  end

  def normalise text
    text.gsub(/[\n]/, ' ').gsub(/\s+/, ' ')
  end
end


module Regression
  include CommandLine

  def stop_mirage
    system "export RUBYOPT='' && cd #{SCRATCH} && mirage stop"
  end

  def start_mirage
    system "export RUBYOPT='' && cd #{SCRATCH} && mirage start"
  end

  def run command
    execute(command)
  end
end

module IntelliJ
  include CommandLine
  include Mirage::Util

  def stop_mirage
    system "cd #{SCRATCH} && #{RUBY_CMD}  ../bin/mirage stop"
  end

  def start_mirage
    system "cd #{SCRATCH} && #{RUBY_CMD} ../bin/mirage start"
  end

  def run command
    execute "#{RUBY_CMD} #{command}"
  end
end

'regression' == ENV['mode'] ? World(Regression) : World(IntelliJ)
'regression' == ENV['mode'] ? include(Regression) : include(IntelliJ)

World(Web)


Before do
  FileUtils.mkdir_p(SCRATCH)
  $mirage = Mirage::Client.new
  if $mirage.running?
    $mirage.clear
  else
    start_mirage
  end

  Dir["#{SCRATCH}/*"].each do |file|
      FileUtils.rm_rf(file) unless file == "#{SCRATCH}/mirage.log"
  end

  @mirage_log_file = File.open("#{SCRATCH}/mirage.log")
  @mirage_log_file.seek(0,IO::SEEK_END)
end

at_exit do
  stop_mirage if $mirage.running?
end