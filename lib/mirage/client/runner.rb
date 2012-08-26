require 'thor'
require 'waitforit'
require 'childprocess'
require 'uri'
module Mirage
  class << self
    include Web

    # Start Mirage locally on a given port
    # Example Usage:
    #
    #   Mirage.start :port => 9001 -> Configured MirageClient ready to use.
    def start options={:port => 7001}
      Runner.new.invoke(:start, [], options)
    end

    # Stop locally running instance(s) of Mirage
    #
    # Example Usage:
    #   Mirage.stop -> Will stop mirage if there is only instance running. Can be running on any port.
    #   Mirage.stop :port => port -> stop mirage on a given port
    #   Mirage.stop :port => [port1, port2...] -> stops multiple running instances of Mirage
    def stop options={}
      options = {:port => :all} if options == :all

      if options[:port]
        options[:port] = [options[:port]] unless options[:port].is_a?(Array)
      end

      Runner.new.invoke(:stop, [], options)
    rescue ClientError => e
      raise ClientError.new("Mirage is running multiple ports, please specify the port(s) see api/tests for details")
    end


    # Detect if Mirage is running on a URL or a local port
    #
    # Example Usage:
    #   Mirage.running? -> boolean indicating whether Mirage is running on *locally* on port 7001
    #   Mirage.running? :port => port -> boolean indicating whether Mirage is running on *locally* on the given port
    #   Mirage.running? url -> boolean indicating whether Mirage is running on the given URL
    def running? options_or_url = {:port => 7001}
      url = options_or_url.is_a?(Hash) ? "http://localhost:#{options_or_url[:port]}/mirage" : options_or_url
      http_get(url) and return true
    rescue Errno::ECONNREFUSED
      return false
    end

  end

  class Runner < Thor
    include ::Mirage::Web
    RUBY_CMD = ChildProcess.jruby? ? 'jruby' : 'ruby'

    desc "start", "Starts mirage"
    method_option :port, :aliases => "-p", :type => :numeric, :default => 7001, :desc => "port that mirage should be started on"
    method_option :defaults, :aliases => "-d", :type => :string, :default => 'responses', :desc => "location to load default responses from"
    method_option :debug, :type => :boolean, :default => false, :desc => "run in debug mode"

    def start
      unless mirage_process_ids([options[:port]]).empty?
        puts "Mirage is already running: #{mirage_process_ids([options[:port]]).values.join(",")}"
        return
      end

      mirage_server_file = "#{File.dirname(__FILE__)}/../../../mirage_server.rb"

      if ChildProcess.windows?
        command = ["cmd", "/C", "start", "mirage server port #{options[:port]}", RUBY_CMD, mirage_server_file]
      else
        command = [RUBY_CMD, mirage_server_file]
      end


      command = command.concat(options.to_a).flatten.collect { |arg| arg.to_s }
      ChildProcess.build(*command).start

      mirage_client = Mirage::Client.new "http://localhost:#{options[:port]}/mirage"
      wait_until(:timeout_after => 30.seconds) { mirage_client.running? }

      begin
        mirage_client.prime
      rescue Mirage::InternalServerException => e
        puts "WARN: #{e.message}"
      end
      mirage_client
    end

    desc "stop", "Stops mirage"
    method_option :port, :aliases => "-p", :type => :array, :banner => "[port_1 port_2|all]", :desc => "port(s) of mirage instance(s). ALL stops all running instances"

    def stop
      ports = options[:port] || []
      if  ports.empty?
        mirage_process_ids = mirage_process_ids([:all])
        raise ClientError.new("Mirage is running on ports #{mirage_process_ids.keys.sort.join(", ")}. Please run mirage stop -p [PORT(s)] instead") if mirage_process_ids.size > 1
      end

      ports = case ports
                when %w(all), [:all], []
                  [:all]
                else
                  ports.collect { |port| port.to_i }
              end

      mirage_process_ids(ports).values.each do |process_id|
        ChildProcess.windows? ? `taskkill /F /T /PID #{process_id}` : IO.popen("kill -9 #{process_id}")
      end

      wait_until do
        mirage_process_ids(ports).empty?
      end
    end

    private

    def processes_with_name name
      if ChildProcess.windows?

        `tasklist /V | findstr "#{name.gsub(" ", '\\ ')}"`
      else
        IO.popen("ps aux | grep '#{name}' | grep -v grep | grep -v #{$$}")
      end
    end

    def mirage_process_ids *ports
      ports.flatten!
      mirage_instances = {}
      ["Mirage Server", "mirage_server", "mirage server"].each do |process_name|
        processes_with_name(process_name).lines.collect { |line| line.chomp }.each do |process_line|
          pid = process_line.split(' ')[1]
          port = process_line[/port (\d+)/, 1]
          mirage_instances[port] = pid
        end
      end

      return mirage_instances if ports.first.to_s.downcase == "all"
      Hash[mirage_instances.find_all { |port, pid| ports.include?(port.to_i) }]
    end

  end
end