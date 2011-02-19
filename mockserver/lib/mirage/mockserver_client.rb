require 'cgi'
require 'open-uri'

MOCK_SERVER_URL = "http://sstp.localhost.bskyb.com:7000/mockserver"

class MockServer
  def self.set name, response, pattern=nil, delay=0
    url = "#{MOCK_SERVER_URL}/set/#{name}?response=#{CGI::escape(response.to_s)}&delay=#{delay}"
    if pattern
      url += "&pattern=#{CGI::escape(pattern.source)}"
    end
    open(url).readlines.to_s
  end

  def self.set_defaults
    open("http://sstp.localhost.bskyb.com:7000/sstp/default")
  end

  def self.check id, part='query'
    CGI::unescape(open("#{MOCK_SERVER_URL}/check/#{id}/#{part}").readlines.to_s)
  end

  def self.clear name='all'
    name == 'all' ? open("#{MOCK_SERVER_URL}/clear/") : open("#{MOCK_SERVER_URL}/clear/responses/#{name}")
  end

  def self.clear_requests
    open("#{MOCK_SERVER_URL}/clear/requests")
  end

  def self.rollback
    open("#{MOCK_SERVER_URL}/rollback")
  end

  def self.snapshot
    open("#{MOCK_SERVER_URL}/snapshot")
  end


  def self.was_hit? id, part='body'
    begin
      open("#{MOCK_SERVER_URL}/check/#{id}/#{part}")
      return true
    rescue
      return false
    end
  end

end
