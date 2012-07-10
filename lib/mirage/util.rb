require 'optparse'
module Mirage
  module Util

    def parse_options args
      options = {:port => 7001, :defaults_directory => 'responses', :root_directory => '.'}

      opt_parser = OptionParser.new do |opts|
        opts.banner = "Usage: mirage start|stop [options]"
        opts.on("-p", "--port PORT", "the port to start Mirage on") do |port|
          options[:port] = port.to_i
        end

        opts.on("-d", "--defaults DIR", "location to load default responses from") do |directory|
          options[:defaults_directory] = directory
        end

        opts.on('--debug', 'run in debug mode') do
          options[:debug] = true
        end
      end

      begin
        opt_parser.parse args
      rescue
        puts opt_parser
        exit 1
      end

      options
    end

    def windows?
      ENV['OS'] == 'Windows_NT'
    end
  end

end