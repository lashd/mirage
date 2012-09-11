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
    end

    client.put('greeting','hello')
    """
    When I send POST to 'http://localhost:7001/mirage/responses/greeting'
    Then 'hello' should be returned
    And a 202 should be returned

  Scenario: Configuring a client after it has been created
    Given I run
    """
    client = Mirage::Client.new
    client.configure do |defaults|
      defaults.method = :post
      defaults.status = 202
    end

    client.put('greeting','hello')
    """
    When I send POST to 'http://localhost:7001/mirage/responses/greeting'
    Then 'hello' should be returned
    And a 202 should be returned



