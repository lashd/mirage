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
      return Template.get("#{@url}/templates/#{id}") if id
      Templates.new(@url)
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

    def == client
      client.instance_of?(Client) && self.url == client.url
    end
  end
end