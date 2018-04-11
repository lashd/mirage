require 'thor'
require 'childprocess'
require 'uri'
require 'httparty'

module Mirage
  class << self

    # Start Mirage locally on a given port
    # Example Usage:
    #
    #   Mirage.start :port => 9001 -> Configured MirageClient ready to use.
    def start options={}
      options={:port => 7001}.merge(options)
      Runner.new.invoke(:start, [], options)
      Mirage::Client.new(options)
    end

    # Stop locally running instance(s) of Mirage
    #
    # Example Usage:
    #   Mirage.stop -> Will stop mirage if there is only instance running. Can be running on any port.
    #   Mirage.stop :port => port -> stop mirage on a given port
    #   Mirage.stop :port => [port1, port2...] -> stops multiple running instances of Mirage
    def stop options={:port => []}
      options = {:port => :all} if options == :all

      if options[:port]
        options[:port] = [options[:port]] unless options[:port].is_a?(Array)
      end

      Runner.new.invoke(:stop, [], options)
    rescue ClientError
      raise ClientError.new("Mirage is running multiple ports, please specify the port(s) see api/tests for details")
    end


    # Detect if Mirage is running on a URL or a local port
    #
    # Example Usage:
    #   Mirage.running? -> boolean indicating whether Mirage is running on *locally* on port 7001
    #   Mirage.running? :port => port -> boolean indicating whether Mirage is running on *locally* on the given port
    #   Mirage.running? url -> boolean indicating whether Mirage is running on the given URL
    def running? options_or_url = {:port => 7001}
      if options_or_url.kind_of?(Hash)
        if options_or_url[:url]
          url = options_or_url[:url]
        else
          url = "http://localhost:#{options_or_url[:port]}"
        end
      else
        url = options_or_url
      end
      HTTParty.get(url) and return true
    rescue Errno::ECONNREFUSED
      return false
    end
  end

  class Runner < Thor
    include CLIBridge
    include Mirage::WaitMethods

    RUBY_CMD = ChildProcess.jruby? ? 'jruby' : 'ruby'

    desc "start", "Starts mirage"
    method_option :port, :aliases => "-p", :type => :numeric, :default => 7001, :desc => "port that mirage should be started on"
    method_option :defaults, :aliases => "-d", :type => :string, :default => 'mirage', :desc => "location to load default responses from"
    method_option :debug, :type => :boolean, :default => false, :desc => "run in debug mode"

    def start
      port = options[:port]
      process_ids = mirage_process_ids([port])
      unless process_ids.empty?
        warn "Mirage is already running: #{process_ids.values.join(",")}"
        return
      end

      mirage_server_file = "#{File.dirname(__FILE__)}/../../../mirage_server.rb"

      if ChildProcess.windows?
        command = ["cmd", "/C", "start", "mirage server port #{port}", RUBY_CMD, mirage_server_file]
      else
        command = [RUBY_CMD, mirage_server_file]
      end


      command = command.concat(options.to_a).flatten.collect { |arg| arg.to_s }
      ChildProcess.build(*command).start

      wait_until(:timeout_after => 30) { Mirage.running?(options) }

      begin
        Mirage::Client.new(options).prime
      rescue Mirage::InternalServerException => e
        puts "WARN: #{e.message}"
      end
    end

    desc "stop", "Stops mirage"
    method_option :port, :aliases => "-p", :type => :array, :default => [], :banner => "[port_1 port_2|all]", :desc => "port(s) of mirage instance(s). ALL stops all running instances"

    def stop
      ports = options[:port].collect{|port| port=~/\d+/ ? port.to_i : port}
      process_ids = mirage_process_ids(ports)
      raise ClientError.new("Mirage is running on ports #{process_ids.keys.sort.join(", ")}. Please run mirage stop -p [PORT(s)] instead") if (process_ids.size > 1 && ports.empty?)
      process_ids.values.each { |process_id| kill process_id }
      wait_until { mirage_process_ids(options[:port]).empty? }
    end

  end
end
