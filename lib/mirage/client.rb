require 'uri'
require 'mechanize'
require 'open-uri'
require 'mirage/web'

module Mirage

  class MirageError < ::Exception
    attr_reader :code

    def initialize message, code
      super message
      @code = message, code
    end
  end

  class InternalServerException < MirageError;
  end

  class ResponseNotFound < MirageError;
  end

  class Client
    include ::Mirage::Web

    # Creates an instance of the MIrage client that can be used to interact with the Mirage Server
    #
    #   Client.new => a client that is configured to connect to Mirage on http://localhost:7001/mirage (the default settings for Mirage)
    #   Client.new(URL) => a client that is configured to connect to an instance of Mirage running on the specified url.
    def initialize url="http://localhost:7001/mirage"
      @url = url
    end

    # Get a response at the given endpoint
    # Mirage::Client.get(endpoint) => response as a string
    # If a response is not found a ResponseNotFound exception is thrown
    #
    #   Examples:
    #   Getting a response, passing request parameters
    #   Mirage::Client.new.get('greeting', :param1 => 'value1', param2=>'value2')
    #
    #   Getting a response, passing a content in the body of the request
    #   Mirage::Client.new.get('greeting',  'content')

    def get endpoint, body_or_params={}
      body_or_params = {:body => body_or_params} if body_or_params.is_a?(String)
      response(http_get("#{@url}/get/#{endpoint}", body_or_params))
    end

    # Set a text or file based response, to be hosted at a given end point optionally with a given pattern and delay
    # Client.set(endpoint, response, params) => unique id that can be used to call back to the server
    #
    #  Examples:
    #  Client.set('greeting', 'hello':)
    #  Client.set('greeting', 'hello', :pattern => 'regex or plain text':)
    #  Client.set('greeting', 'hello', :delay => 5) # number of seconds
    def set endpoint, response, params={}
      params[:response] = response
      response(http_post("#{@url}/set/#{endpoint}", params))
    end

    # Use to look at what a response contains without actually triggering it.
    # Client.peek(response_id) => response held on the server as a String
    def peek response_id
      response(http_get("#{@url}/peek/#{response_id}"))
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
        when NilClass then
          http_get("#{@url}/clear")
        when Fixnum then
          http_get("#{@url}/clear/#{thing}")
        when :requests then
          http_get("#{@url}/clear/requests")
        when Hash then
          case thing.keys.first
            when :request then
              http_get("#{@url}/clear/request/#{thing.values.first}")
          end
      end
    end


    # Retrieve the last request that triggered a response to be returned. If the request contained content in its body, this is returned. If the
    # request did not have any content in its body then what ever was in the request query string is returned instead
    #
    #   Example:
    #   Client.new.track(response_id) => Tracked request as a String
    def track response_id
      response(http_get("#{@url}/track/#{response_id}"))
    end

    # Save the state of the Mirage server so that it can be reverted back to that exact state at a later time.
    def save
      http_post("#{@url}/save").code == 200
    end


    # Revert the state of Mirage back to the state that was last saved
    # If there is no snapshot to rollback to, nothing happens
    def revert
      http_post("#{@url}/revert").code == 200
    end


    # Check to see if Mirage is up and running
    def running?
      !http_get(@url).is_a?(Errno::ECONNREFUSED)
    end

    # Clear down the Mirage Server and load any defaults that are in Mirages default responses directory.
    def prime
      response(http_post("#{@url}/prime"))
    end

    private
    def response response
      return Mirage::Web::FileResponse.new(response) if response.instance_of?(Mechanize::File)
      case response.code
        when 500 then
          raise ::Mirage::InternalServerException.new(response.page.body, response.code)
        when 404 then
          raise ::Mirage::ResponseNotFound.new(response.page.body, response.code)
        else
          response.body
      end
    end

  end


end