require 'uri'
require 'httparty'
require 'base64'
require 'json'

module Mirage
  class Client
    include HTTParty

    attr_reader :url

    def initialize options={:url => "http://localhost:7001"}, &block
      if options.is_a?(String) && options =~ URI.regexp
        @url = options
      elsif options.kind_of?(Hash) && options[:url]
        @url = options[:url]
      elsif options.kind_of?(Hash) && options[:port]
        @url = "http://localhost:#{options[:port]}"
      else
        raise "specify a valid URL or port"
      end

      @templates = Templates.new(@url)
      @templates.default_config &block if block
    end

    def configure &block
      templates.default_config &block if block
    end

    def reset
      templates.default_config.reset
    end

    def templates id=nil
      return Template.get("#{@url}/templates/#{id}") if id
      @templates
    end

    def requests id=nil
      return Request.get "#{@url}/requests/#{id}" if id
      Requests.new(@url)
    end

    def prime
      self.class.send(:put, "#{@url}/defaults", :body => "")
    end

    def save
      self.class.send(:put, "#{@url}/backup", :body => "")
    end

    def revert
      self.class.send(:put, @url, :body => "")
    end

    def put *args, &block
      templates.put *args, &block
    end

    def clear
      templates.delete_all
    end

    def == client
      client.instance_of?(Client) && self.url == client.url
    end

    def running?
      Mirage.running? @url
    end
  end
end