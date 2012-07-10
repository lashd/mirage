@command_line
Feature: The Mirage client provides a programmatic interface equivalent to the command line interface. This gives an
  easy method for bringing a local instance of Mirage in situ inside a test suite.

  The client can only be used to stop Mirage if it is was used to start the running instance.

  Background:
    Given the following gems are required to run the Mirage client test code:
    """
    require 'rubygems'
    require 'rspec'
    require 'mirage/client'
    """


  Scenario: Starting mirage with defaults
    Given Mirage is not running
    When I run
    """
    Mirage.start
    """
    Then mirage should be running on 'http://localhost:7001/mirage'


  Scenario: Stopping Mirage
    Given Mirage is not running
    When I run
    """
    Mirage.start
    Mirage.stop
    """
    Then Connection should be refused to 'http://localhost:7001/mirage'


  Scenario: Starting Mirage on a custom port
    Given Mirage is not running
    And the file './custom_responses_location/default_greetings.rb' contains:
    """
    prime do |mirage|
      mirage.put('greeting', 'hello')
    end
    """
    When I run
    """
    Mirage.start :port => 9001, :defaults => './custom_responses_location'
    """
    And I send GET to 'http://localhost:9001/mirage/responses/greeting'
    Then 'hello' should be returned