module Mirage
  module Util
    def wait_until time=30
      start_time = Time.now
      until Time.now >= start_time + time
        sleep 0.1
        return if yield
      end
      raise 'timeout waiting'
    end

    def parse_options args
      options = {:port => 7001, :defaults_directory => 'defaults', :root_directory => '.'}

      begin
        opt_parser.parse args
      rescue
        print_usage
        exit 1
      end
      options
    end

    def print_usage
      puts "mirage start|stop [OPTIONS]"
      puts opt_parser
    end

    private
    def opt_parser
      OptionParser.new do |opts|
        opts.on("-p", "--port PORT", "the port to start Mirage on") do |port|
          options[:port] = port.to_i
        end

        opts.on("-d", "--defaults DIR", "location to load default responses from") do |directory|
          options[:defaults_directory] = directory
        end
      end
    end
  end

end