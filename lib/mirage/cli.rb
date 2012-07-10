module Mirage
  class CLI
    extend Mirage::Util
    RUBY_CMD = RUBY_PLATFORM == 'java' ? 'jruby' : 'ruby'
    class << self


      def parse_options args
        options = {:port => 7001, :defaults => 'responses', :root_directory => '.'}

        opt_parser = OptionParser.new do |opts|
          opts.banner = "Usage: mirage start|stop [options]"
          opts.on("-p", "--port PORT", "the port to start Mirage on") do |port|
            options[:port] = port.to_i
          end

          opts.on("-d", "--defaults DIR", "location to load default responses from") do |directory|
            options[:defaults] = directory
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

      def run args

        unless mirage_process_ids.empty?
          puts "Mirage is already running"
          exit 1
        end

        puts "Starting Mirage"

        if windows?
          command = ["cmd", "/C", "start", "mirage server", RUBY_CMD, "#{File.dirname(__FILE__)}/../../mirage_server.rb"]
        else
          command = [RUBY_CMD, "#{File.dirname(__FILE__)}/../../mirage_server.rb"]
        end


        puts *(command.concat(args))
        process = ChildProcess.build(*(command.concat(args)))
        process.start
        process
      end

      def stop
        mirage_process_ids.each { |process_id| windows? ? `taskkill /F /T /PID #{process_id}` : `kill -9 #{process_id}` }
        wait_until{ mirage_process_ids.size == 0 }
      end

      private
      def mirage_process_ids
        if windows?
          [`tasklist /V | findstr "mirage\\ server"`.split(' ')[1]].compact
        else
          ["Mirage Server", 'mirage_server'].collect do |process_name|
            `ps aux | grep "#{process_name}" | grep -v grep`.split(' ')[1]
          end.find_all { |process_id| process_id != $$.to_s }.compact
        end
      end
    end
  end
end
