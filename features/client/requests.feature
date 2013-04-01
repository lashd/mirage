Feature: Requests made to the Mirage Server can be tracked using the Mirage client

  Background:
    Given the following gems are required to run the Mirage client test code:
    """
    require 'rubygems'
    require 'rspec'
    require 'mirage/client'
    """

  Scenario: The MockServer returns a response
    Given a template for 'greeting' has been set with a value of 'Hello'

    When I send GET to 'http://localhost:7001/mirage/responses/greeting' with parameters:
      | name | leon  |
    Then I run
    """
       Mirage::Client.new.requests(1).parameters.should == {'name' => 'leon'}
    """