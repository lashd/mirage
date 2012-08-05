$LOAD_PATH.unshift "#{File.dirname(__FILE__)}"
require 'uri'
require 'waitforit'
require 'childprocess'
require 'client/web'
require 'ostruct'
require 'optparse'
require 'thor'

module Mirage

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

      mirage_server_file = "#{File.dirname(__FILE__)}/../../mirage_server.rb"

      if ChildProcess.windows?
        command = ["cmd", "/C", "start", "mirage server", RUBY_CMD, mirage_server_file]
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

    desc "stop", "stops mirage"
    method_option :port, :aliases => "-p", :type => :array, :banner => "[port_1 port_2|all]", :desc => "port(s) of mirage instance(s). ALL stops all running instances"

    def stop

      ports = options[:port]
      if ports.nil?
        mirage_process_ids = mirage_process_ids([:all])
        raise "Mirage is running on ports #{mirage_process_ids.keys.join(", ")}. Please run mirage stop -p [PORT(s)] instead" if mirage_process_ids.size > 1
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
    def mirage_process_ids ports

      mirage_instances = {}
      if ports.first.to_s.downcase == "all"
        if ChildProcess.windows?
          [`tasklist /V | findstr "mirage\\ server"`.split(' ')[1]].compact
        else
          ["Mirage Server", "mirage_server"].each do |process_name|
            `ps aux | grep "#{process_name}" | grep -v grep`.chomp.lines.collect{|line|line.chomp}.each do |process_line|
              pid = process_line.split(' ')[1]
              port = process_line[/port (\d+)/,1]
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


  class << self


    def start options={:port => 7001}
      Runner.new.invoke(:start, [], options)
    end

    def stop options
      options[:port] = [options[:port]] unless options[:port].is_a?(Array)
      puts "Stopping Mirage"
      Runner.new.invoke(:stop, [], options)
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

  class MirageError < ::Exception
    attr_reader :code

    def initialize message, code
      super message
      @code = message, code
    end
  end

  class Response < OpenStruct

    attr_accessor :content_type
    attr_reader :value

    def initialize response
      @content_type = 'text/plain'
      @value = response
      super({})
    end

    def headers
      headers = {}

      @table.each { |header, value| headers["X-mirage-#{header.to_s.gsub('_', '-')}"] = value }
      headers['Content-Type']=@content_type
      headers['X-mirage-file'] = 'true' if @response.kind_of?(IO)

      headers
    end

  end

  class InternalServerException < MirageError;
  end

  class ResponseNotFound < MirageError;
  end

  class Client
    include ::Mirage::Web
    attr_reader :url

    # Creates an instance of the MIrage client that can be used to interact with the Mirage Server
    #
    #   Client.new => a client that is configured to connect to Mirage on http://localhost:7001/mirage (the default settings for Mirage)
    #   Client.new(URL) => a client that is configured to connect to an instance of Mirage running on the specified url.
    def initialize url="http://localhost:7001/mirage"
      @url = url
    end

    def stop
      Mirage.stop :port => URI.parse(@url).port
    end


    # Set a text or file based response template, to be hosted at a given end point. A block can be specified to configure the template
    # Client.set(endpoint, response, &block) => unique id that can be used to call back to the server
    #
    # Examples:
    # Client.put('greeting', 'hello')
    #
    # Client.put('greeting', 'hello') do |response|
    #   response.pattern = 'pattern' #regex or string literal applied against the request querystring and body
    #   response.method = :post #By default templates will respond to get requests
    #   response.content_type = 'text/html' #defaults text/plain
    #   response.default = true # defaults to false. setting to true will allow this template to respond to request made to sub resources should it match.
    # end
    def put endpoint, response_value, &block
      response = Response.new response_value

      yield response if block_given?

      build_response(http_put("#{@url}/templates/#{endpoint}", response.value, response.headers))
    end

    # Use to look at what a response contains without actually triggering it.
    # client.response(response_id) => response held on the server as a String
    def response response_id
      response = build_response(http_get("#{@url}/templates/#{response_id}"))
      case response
        when String then
          return response
        when Mirage::Web::FileResponse then
          return response.response.body
      end

    end

    # Clear Content from Mirage
    #
    # If a response id is not valid, a ResponseNotFound exception will be thrown
    #
    #   Examples:
    #   Client.new.clear # clear all responses and associated requests
    #   Client.new.clear(response_id) # Clear the response and tracked request for a given response id
    #   Client.new.clear(:requests) # Clear all tracked request information
    #   Client.new.clear(:request => response_id) # Clear the tracked request for a given response id
    def clear thing=nil

      case thing
        when :requests
          http_delete("#{@url}/requests")
        when Numeric then
          http_delete("#{@url}/templates/#{thing}")
        when Hash then
          puts "deleteing request #{thing[:request]}"
          http_delete("#{@url}/requests/#{thing[:request]}") if thing[:request]
        else
          NilClass
          http_delete("#{@url}/templates")
      end

    end


    # Retrieve the last request that triggered a response to be returned. If the request contained content in its body, this is returned. If the
    # request did not have any content in its body then what ever was in the request query string is returned instead
    #
    #   Example:
    #   Client.new.track(response_id) => Tracked request as a String
    def request response_id
      build_response(http_get("#{@url}/requests/#{response_id}"))
    end

    # Save the state of the Mirage server so that it can be reverted back to that exact state at a later time.
    def save
      http_put("#{@url}/backup", '').code == 200
    end


    # Revert the state of Mirage back to the state that was last saved
    # If there is no snapshot to rollback to, nothing happens
    def revert
      http_put("#{@url}", '').code == 200
    end


    # Check to see if Mirage is up and running
    def running?
      begin
        http_get(@url) and return true
      rescue Errno::ECONNREFUSED
        return false
      end
    end

    # Clear down the Mirage Server and load any defaults that are in Mirages default responses directory.
    def prime
      puts "#{@url}/defaults"
      build_response(http_put("#{@url}/defaults", ''))
    end

    private
    def build_response response
      case response.code.to_i
        when 500 then
          raise ::Mirage::InternalServerException.new(response.body, response.code.to_i)
        when 404 then
          raise ::Mirage::ResponseNotFound.new(response.body, response.code.to_i)
        else
          response.body
      end
    end

  end


end