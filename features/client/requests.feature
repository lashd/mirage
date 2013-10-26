Feature: Retrieving tracked requests

  Requests made to the Mirage Server can be retrieved using the Mirage client

  Background:
    Given the following require statements are needed:
    """
    require 'rubygems'
    require 'mirage/client'
    """

  Scenario: Retrieving request data
    Given a template for 'greeting' has been set with a value of 'Hello'

    When I send GET to '/responses/greeting' with parameters:
      | name | leon  |
    Then I run
    """
       Mirage::Client.new.requests(1).parameters.should == {'name' => 'leon'}
    """