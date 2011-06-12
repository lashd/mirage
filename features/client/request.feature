Feature: Requests made to the Mirage Server can be tracked using the Mirage client

  Background:
    Given the following gems are required to run the Mirage client test code:
    """
    require 'rubygems'
    require 'rspec'
    require 'mirage/client'
    """

  Scenario: The MockServer returns a response
    Given I send PUT to 'http://localhost:7001/mirage/templates/greeting' with request entity
    """
    Hello
    """

    When I send GET to 'http://localhost:7001/mirage/responses/greeting' with parameters:
      | name | leon  |
    Then I run
    """
       Mirage::Client.new.request(1).should == 'name=leon'
    """