require 'uri'
require 'httparty'
require 'base64'
require 'json'

module Mirage
  class Client
    include HTTParty

    attr_reader :url


    def initialize options={:url => "http://localhost:7001/mirage"}
      if options.is_a?(String) && options =~ URI.regexp
        warn("Client.new(url): Deprecated usage, please use :url => url | :port => port")
        @url = options
      elsif options.kind_of?(Hash) && options[:port]
        @url = "http://localhost:#{options[:port]}/mirage"
      elsif options.kind_of?(Hash) && options[:url]
        @url = options[:url]
      else
        raise "specify a valid URL or port"
      end
    end

    def templates id=nil
      return Template.get("#{@url}/#{id}") if id
      Templates.new(@url)

    end

    def requests id=nil
      return Request.get "#{@url}/#{id}" if id
      Requests.new(@url)
    end

    def prime
      self.class.send(:put, "#{@url}/defaults")
    end

    def == client
      client.instance_of?(Client) && self.url == client.url
    end
  end

  #class Client
  #  Defaults = Struct.new(:method, :status, :delay, :content_type, :default)
  #  include Mirage::Web
  #  attr_reader :url
  #
  #
  #  # Creates an instance of the Mirage client that can be used to interact with the Mirage Server
  #  #
  #  #   Client.new => a client that is configured to connect to Mirage on http://localhost:7001/mirage (the default settings for Mirage)
  #  #   Client.new(URL) => a client that is configured to connect to an instance of Mirage running on the specified url.
  #  #   Client.new(hash) => a client that is configured to connect to an instance of Mirage running on the specified url or localhost port.
  #  #     e.g: Client.new(:url => url) or Client.new(:port => port)
  #  #
  #  #   a block can be passed to configure the client with defaults: see configure
  #  def initialize options={:url => "http://localhost:7001/mirage"}, &block
  #    if options.is_a?(String) && options =~ URI.regexp
  #      warn("Client.new(url): Deprecated usage, please use :url => url | :port => port")
  #      @url = options
  #    elsif options.kind_of?(Hash) && options[:port]
  #      @url = "http://localhost:#{options[:port]}/mirage"
  #    elsif options.kind_of?(Hash) && options[:url]
  #      @url = options[:url]
  #    else
  #      raise "specify a valid URL or port"
  #    end
  #
  #    reset
  #    configure &block if block_given?
  #  end
  #
  #
  #  # Configures default settings to be applied to all response templates put on to Mirage
  #  #
  #  #   Example:
  #  #   Client.new.configure do
  #  #     defaults.method = :post
  #  #     defaults.status = 202
  #  #     defaults.default = true
  #  #     defaults.delay = 2
  #  #     defaults.content_type = "text/xml"
  #  #   end
  #  def configure &block
  #    yield @defaults
  #  end
  #
  #  # Remove any defaults applied to this client
  #  def reset
  #    @defaults = Defaults.new
  #  end
  #
  #  def stop
  #    Mirage.stop :port => URI.parse(@url).port
  #  end
  #
  #
  #  # Set a text or file based response template, to be hosted at a given end point. A block can be specified to configure the template
  #  # client.set(endpoint, response, &block) => unique id that can be used to call back to the server
  #  #
  #  # Examples:
  #  # client.put('greeting', 'hello')
  #  #
  #  # client.put('greeting', 'hello') do |response|
  #  #   response.add_body_content_requirement(pattern) #regex or string literal applied against the body
  #  #   response.add_request_parameter_requirement(name,pattern) name of parameter and #regex or string that should be used to match against its value
  #  #   response.pattern = 'pattern' #regex or string literal applied against the request querystring and body
  #  #   response.method = :post #By default templates will respond to get requests
  #  #   response.content_type = 'text/html' #defaults text/plain
  #  #   response.default = true # defaults to false. setting to true will allow this template to respond to request made to sub resources should it match.
  #  # end
  #  def put endpoint, response_value, &block
  #    response = Mirage::Response.new response_value
  #    @defaults.each_pair { |key, value| response.send("#{key}=", value) if value }
  #    yield response if block_given?
  #
  #    build_response(http_put("#{@url}/templates/#{endpoint}", response.value, :headers => response.headers))
  #  end
  #
  #  # Use to look to preview the content of a response template would return to a client without actually triggering.
  #  # client.response(response_id) => response held on the server as a String
  #  def response response_id
  #    response = build_response(http_get("#{@url}/templates/#{response_id}"))
  #    case response
  #      when String then
  #        return response
  #      when Mirage::Web::FileResponse then
  #        return response.response.body
  #    end
  #
  #  end
  #
  #  # Clear Content from Mirage
  #  #
  #  # If a response id is not valid, a ResponseNotFound exception will be thrown
  #  #
  #  # Example Usage:
  #  #   client.clear -> clear all responses and associated requests
  #  #   client.clear(response_id) -> Clear the response and tracked request for a given response id
  #  #   client.clear(:requests) -> Clear all tracked request information
  #  #   client.clear(:request => response_id) -> Clear the tracked request for a given response id
  #  def clear thing=nil
  #
  #    case thing
  #      when :requests
  #        http_delete("#{@url}/requests")
  #      when Numeric then
  #        http_delete("#{@url}/templates/#{thing}")
  #      when Hash then
  #        puts "deleteing request #{thing[:request]}"
  #        http_delete("#{@url}/requests/#{thing[:request]}") if thing[:request]
  #      else
  #        NilClass
  #        http_delete("#{@url}/templates")
  #    end
  #
  #  end
  #
  #
  #  # Retrieve the last request that triggered a response to be returned. If the request contained content in its body, this is returned. If the
  #  # request did not have any content in its body then what ever was in the request query string is returned instead
  #  #
  #  # Example Usage
  #  #   client.request(response_id) -> Tracked request as a String
  #  def request response_id
  #    build_response(http_get("#{@url}/requests/#{response_id}"))
  #  end
  #
  #  # Save the state of the Mirage server so that it can be reverted back to that exact state at a later time.
  #  def save
  #    http_put("#{@url}/backup", '').code == 200
  #  end
  #
  #
  #  # Revert the state of Mirage back to the state that was last saved
  #  # If there is no snapshot to rollback to, nothing happens
  #  def revert
  #    http_put(@url, '').code == 200
  #  end
  #
  #
  #  # Check to see if mirage is running on the url that the client is pointing to
  #  def running?
  #    Mirage.running?(@url)
  #  end
  #

  #
  #  def == client
  #    client.is_a?(Client) && @url == client.url
  #  end
  #
  #  private
  #  def build_response response
  #    case response.code.to_i
  #      when 500 then
  #        raise ::Mirage::InternalServerException.new(response.body, response.code.to_i)
  #      when 404 then
  #        raise ::Mirage::ResponseNotFound.new(response.body, response.code.to_i)
  #      else
  #        response.body
  #    end
  #  end
  #end
end