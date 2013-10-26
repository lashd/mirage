Feature: Configuring Templates

  If you find yourself setting the same basic http settings for templates, the client can be configured to preset these.

  Background:
    Given the following gems are required to run the Mirage client test code:
    """
    require 'rubygems'
    require 'rspec'
    require 'mirage/client'
    """

  Scenario: configuring the client on instance
    Given I run
    """
    client = Mirage::Client.new do
      http_method :post
      status 202
      default true
      delay 2
      content_type "text/xml"
    end

    client.put('greeting','hello')
    """
    When POST is sent to '/responses/greeting/for/someone'
    Then 'hello' should be returned
    And a 202 should be returned
    Then it should take at least '2' seconds
    And the response 'content-type' should be 'text/xml'

  Scenario: Configuring a client after it has been created
    Given I run
    """
    client = Mirage::Client.new
    client.configure do
      http_method :post
      status 202
      default false
      delay 2
      content_type "text/xml"
    end

    client.put('greeting','hello')
    """
    When POST is sent to '/responses/greeting'
    Then 'hello' should be returned
    And a 202 should be returned
    Then it should take at least '2' seconds
    And the response 'content-type' should be 'text/xml'

  Scenario: resetting defaults
    Given I run
    """
    client = Mirage::Client.new
    client.configure do
      http_method :post
      status 202
      default true
      delay 2
      content_type "text/xml"
    end

    client.reset
    client.put('greeting','hello')
    """
    When GET is sent to '/responses/greeting'
    Then 'hello' should be returned




