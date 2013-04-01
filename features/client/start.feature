@command_line
Feature: The client API can be used to start Mirage.

  Both the port and default templates directory can be specified

  On starting Mirage a client is returned.


  Background:
    Given the following require statements are needed:
    """
    require 'rubygems'
    require 'mirage/client'
    """

  Scenario: Starting Mirage on the default port
    When I run
    """
    Mirage.start
    """
    Then mirage should be running on 'http://localhost:7001/mirage'


  Scenario: Starting Mirage on a custom port
    When I run
    """
    Mirage.start :port => 9001
    """
    Then mirage should be running on 'http://localhost:9001/mirage'


  Scenario: Specifying a custom templates directory.
    And the file './custom_responses_location/default_greetings.rb' contains:
    """
    prime do |mirage|
      mirage.templates.put('greeting', 'hello')
    end
    """
    When I run
    """
    Mirage.start :defaults => './custom_responses_location'
    """
    And GET is sent to 'http://localhost:7001/mirage/responses/greeting'
    Then 'hello' should be returned