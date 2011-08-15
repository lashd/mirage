$LOAD_PATH.unshift "#{File.dirname(__FILE__)}"
require 'uri'
require 'open-uri'
require 'client/web'

module Mirage

  class MirageError < ::Exception
    attr_reader :code

    def initialize message, code
      super message
      @code = message, code
    end
  end
  
  class Response
    
    attr_accessor :method, :pattern, :content_type, :default
    
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


    # Set a text or file based response, to be hosted at a given end point optionally with a given pattern and delay
    # Client.set(endpoint, response, params) => unique id that can be used to call back to the server
    #
    #  Examples:
    #  Client.set('greeting', 'hello':)
    #  Client.set('greeting', 'hello', :pattern => /regexp/)
    #  Client.set('greeting', 'hello', :pattern => 'text')
    #  Client.set('greeting', 'hello', :delay => 5) # number of seconds
    def put endpoint, response_value, params={}
      response = Response.new
      
      yield response if block_given?
      
      headers = {}
      headers['X-mirage-method'] = response.method.to_s if response.method
      
      headers['X-mirage-pattern'] = response.pattern if response.pattern
      headers['X-mirage-default'] = 'true' if response.default
      headers['Content-Type'] = response.content_type || 'text/plain'
      
      build_response(http_put("#{@url}/templates/#{endpoint}",response_value, headers))
    end

    # Use to look at what a response contains without actually triggering it.
    # Client.peek(response_id) => response held on the server as a String
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
        else NilClass
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
      http_put("#{@url}/backup",'').code == 200
    end


    # Revert the state of Mirage back to the state that was last saved
    # If there is no snapshot to rollback to, nothing happens
    def revert
      http_put("#{@url}",'').code == 200
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
      build_response(http_put("#{@url}/defaults",''))
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