Feature: The client can be configured with default settings to keep your mocking 'DRY'

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
    client = Mirage::Client.new do |defaults|
      defaults.method = :post
      defaults.status = 202
      defaults.default = true
      defaults.delay = 2
      defaults.content_type = "text/xml"
    end

    client.put('greeting','hello')
    """
    When I send POST to 'http://localhost:7001/mirage/responses/greeting/for/someone'
    Then 'hello' should be returned
    And a 202 should be returned
    Then it should take at least '2' seconds
    And the response 'content-type' should be 'text/xml'

  Scenario: Configuring a client after it has been created
    Given I run
    """
    client = Mirage::Client.new
    client.configure do |defaults|
      defaults.method = :post
      defaults.status = 202
      defaults.default = true
      defaults.delay = 2
      defaults.content_type = "text/xml"
    end

    client.put('greeting','hello')
    """
    When I send POST to 'http://localhost:7001/mirage/responses/greeting/for/someone'
    Then 'hello' should be returned
    And a 202 should be returned
    Then it should take at least '2' seconds
    And the response 'content-type' should be 'text/xml'

  Scenario: resetting defaults
    Given I run
    """
    client = Mirage::Client.new
    client.configure do |defaults|
      defaults.method = :post
      defaults.status = 202
      defaults.default = true
      defaults.delay = 2
      defaults.content_type = "text/xml"
    end

    client.reset

    client.configure do |defaults|
      defaults.method.should == nil
      defaults.status.should == nil
      defaults.default.should == nil
      defaults.delay.should == nil
      defaults.content_type.should == nil
    end
    """



