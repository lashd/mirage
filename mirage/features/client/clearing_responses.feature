Feature: The client can be used for clearing responses from Mirage

  Background:
    Given the following code snippet is included when running code:
    """
    require 'rubygems'
    require 'rspec'
    require 'mirage'
    """
    And I hit 'http://localhost:7001/mirage/set/greeting' with parameters:
      | response | Hello |

    And getting 'greeting' with request body:
    """
    Hello there
    """
    And I hit 'http://localhost:7001/mirage/set/leaving' with parameters:
      | response | Goodbye |

    And getting 'greeting' with request body:
    """
    I'm going
    """

  Scenario: Clearing everything
    When run
    """
    Mirage::Client.new.clear
    """
    And I hit 'http://localhost:7001/mirage/get/greeting'
    Then a 404 should be returned
    And tracking the request for response id '1' should return a 404
    And I hit 'http://localhost:7001/mirage/get/leaving'
    Then a 404 should be returned
    And tracking the request for response id '1' should return a 404

  Scenario: Clearing all requests
    When run
    """
    Mirage::Client.new.clear :requests
    """
    Then tracking the request for response id '1' should return a 404
    And tracking the request for response id '2' should return a 404

  Scenario: Clearning a response
    Given run
    """
    Mirage::Client.new.clear 1
    """
    When I hit 'http://localhost:7001/mirage/get/greeting'
    Then a 404 should be returned
    And tracking the request for response id '1' should return a 404

  Scenario: Clearning a request
    Given run
    """
    Mirage::Client.new.clear :request => 1
    """
    Then tracking the request for response id '1' should return a 404






