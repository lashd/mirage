#!/usr/bin/ruby
require 'rubygems'
require "#{File.dirname(__FILE__)}/mockserver_core"
require "#{File.dirname(__FILE__)}/mockserver_client"
require 'rake'
require 'optparse'


class SstpMockserverController < Ramaze::Controller
  map '/sstp'




  def index

    @responses = {}
    
    MockServerCore::RESPONSES.each do|name, responses|
      @responses[name]=responses.default unless responses.default.nil? 

      responses.each do |pattern, response|
        @responses["#{name}: #{pattern.source}"] = response
      end
    end
  end
  
  def default
    MockServer.clear
    FileList.new("stub/*.rb").each { |entry| load entry }
    "defaults set"
  end

  def signin
  end

  def login
    username = request['username']
    cookies = {
        'ust' => username.match(/^secondary.*/) ? 'S' : 'P',
        'uifd' => 'Mr firstname lastname',
        'skySSO' => username,
        'hant' => username,
        'just' => username.hash,
        'partyid' => username
    }

    cookies.each{|name, value| set_cookie(name, value)}

    response.redirect(request['successUrl'], 302)
  end

  def features
  end

  def enable feature
    set_cookie(feature, 'true')
    "enabled #{feature}"
  end

  def disable feature
    set_cookie(feature, 'false')
    "disabled #{feature}"
  end

  private
  def set_cookie(feature, value)
    response.set_cookie(feature,
                        :domain=>'.bskyb.com',
                        :expires => (Time.now + 60 * 60),
                        :path => '/',
                        :value=>value)
  end

end
#
#OptionParser.new do |opts|
#  opts.on("-l", "--log FILE", "log to: file_name") do |log|
#    Ramaze::Log.loggers = [Logger.new(log)]
#  end
#end.parse!
#
#Ramaze.start



