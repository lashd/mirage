require 'thor'
require 'waitforit'
require 'childprocess'
module Mirage
  class << self
    def start options={:port => 7001}
      Runner.new.invoke(:start, [], options)
    end

    def stop options={}
      unless options.is_a? Hash
        options[:port] = [options[:port]] if options[:port]
      end
      puts "Stopping Mirage"
      Runner.new.invoke(:stop, [], options)
    rescue ClientError => e
      raise ClientError.new("Mirage is running multiple ports, please specify the port(s) see api/tests for details")
    end

    private
    def convert_to_command_line_argument_array(args)
      command_line_arguments = {}
      args.each do |key, value|
        command_line_arguments["--#{key}"] = "#{value}"
      end
      command_line_arguments.to_a.flatten
    end
  end

  class Runner < Thor
    include ::Mirage::Web
    RUBY_CMD = RUBY_PLATFORM == 'java' ? 'jruby' : 'ruby'

    desc "start", "Starts mirage"
    method_option :port, :aliases => "-p", :type => :numeric, :default => 7001, :desc => "port that mirage should be started on"
    method_option :defaults, :aliases => "-d", :type => :string, :default => 'responses', :desc => "location to load default responses from"
    method_option :debug, :type => :boolean, :default => false, :desc => "run in debug mode"

    def start

      unless mirage_process_ids([options[:port]]).empty?
        puts "Mirage is already running: #{mirage_process_ids([options[:port]])}"
        return
      end

      mirage_server_file = "#{File.dirname(__FILE__)}/../../../mirage_server.rb"

      if ChildProcess.windows?
        command = ["cmd", "/C", "start", "mirage server", RUBY_CMD, mirage_server_file]
      else
        command = [RUBY_CMD, mirage_server_file]
      end


      command = command.concat(options.to_a).flatten.collect { |arg| arg.to_s }
      process = ChildProcess.build(*command)
      process.detach
      #process.io.inherit!
      process.start

      mirage_client = Mirage::Client.new "http://localhost:#{options[:port]}/mirage"
      wait_until(:timeout_after => 30.seconds) { mirage_client.running? }

      begin
        mirage_client.prime
      rescue Mirage::InternalServerException => e
        puts "WARN: #{e.message}"
      end
      mirage_client
    end

    desc "stop", "stops mirage"
    method_option :port, :aliases => "-p", :type => :array, :banner => "[port_1 port_2|all]", :desc => "port(s) of mirage instance(s). ALL stops all running instances"

    def stop

      ports = options[:port]
      if ports.nil?
        mirage_process_ids = mirage_process_ids([:all])
        raise ClientError.new("Mirage is running on ports #{mirage_process_ids.keys.join(", ")}. Please run mirage stop -p [PORT(s)] instead") if mirage_process_ids.size > 1
        ports = [:all]
      end

      mirage_process_ids(ports).values.each do |process_id|
        puts "killing #{process_id}"
        ChildProcess.windows? ? `taskkill /F /T /PID #{process_id}` : `kill -9 #{process_id}`
      end

      wait_until do
        mirage_process_ids(ports).size == 0
      end
    end

    private
    def mirage_process_ids *ports
      ports.flatten!
      mirage_instances = {}
      if ports.first.to_s.downcase == "all"
        if ChildProcess.windows?
          [`tasklist /V | findstr "mirage\\ server"`.split(' ')[1]].compact
        else
          ["Mirage Server", "mirage_server"].each do |process_name|
            `ps aux | grep "#{process_name}" | grep -v grep`.chomp.lines.collect { |line| line.chomp }.each do |process_line|
              pid = process_line.split(' ')[1]
              port = process_line[/port (\d+)/, 1]
              mirage_instances[port] = pid
            end
          end.flatten.find_all { |process_id| process_id != $$.to_s }.compact
        end
      else
        ports.collect do |port|
          begin
            pid = http_get("http://localhost:#{port}/mirage/pid").body.to_i
            mirage_instances[port] = pid
          rescue
            nil
          end
        end.compact
      end

      mirage_instances
    end

  end
end
