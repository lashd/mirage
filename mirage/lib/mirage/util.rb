class Mirage
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
      options = {:port => 7001}

      OptionParser.new(args) do |opts|
        opts.on("-p", "--port PORT", "the port to start Mirage on") do |port|
          puts "options are #{port}"
          options[:port] = port.to_i
        end
      end.parse!

      options
    end

  end

end