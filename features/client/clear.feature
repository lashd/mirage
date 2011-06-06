Feature: The client can be used for clearing responses from Mirage

  Background:
    Given the following gems are required to run the Mirage client test code:
    """
    require 'rubygems'
    require 'rspec'
    require 'mirage'
    """
    
    And I send PUT to 'http://localhost:7001/mirage/templates/greeting' with request entity
    """
    Hello
    """
    And I send GET to 'http://localhost:7001/mirage/responses/greeting' with parameters:
      | message | hello there |
    
    And I send PUT to 'http://localhost:7001/mirage/templates/leaving' with request entity
    """
    Goodbye
    """
    And I send GET to 'http://localhost:7001/mirage/responses/greeting' with parameters:
    | message | I'm going |

    
  Scenario: Clearing everything
    When I run
    """
    Mirage::Client.new.clear
    """
    And I send GET to 'http://localhost:7001/mirage/responses/greeting'
    Then a 404 should be returned

    When I send GET to 'http://localhost:7001/mirage/requests/1'
    Then a 404 should be returned

    And I send GET to 'http://localhost:7001/mirage/responses/leaving'
    Then a 404 should be returned

    When I send GET to 'http://localhost:7001/mirage/requests/2'
    Then a 404 should be returned


  Scenario: Clearing all requests
    When I run
    """
    Mirage::Client.new.clear :requests
    """
    When I send GET to 'http://localhost:7001/mirage/requests/1'
    Then a 404 should be returned

    When I send GET to 'http://localhost:7001/mirage/requests/2'
    Then a 404 should be returned
    
    When I send GET to 'http://localhost:7001/mirage/responses/greeting'
    Then a 200 should be returned
    When I send GET to 'http://localhost:7001/mirage/responses/leaving'
    Then a 200 should be returned
    

  Scenario: Clearning a response
    Given I run
    """
    Mirage::Client.new.clear 1 
    """
    When I send GET to 'http://localhost:7001/mirage/responses/greeting'
    Then a 404 should be returned
    When I send GET to 'http://localhost:7001/mirage/requests/1'
    Then a 404 should be returned
    When I send GET to 'http://localhost:7001/mirage/responses/leaving'
    Then a 200 should be returned
    When I send GET to 'http://localhost:7001/mirage/requests/2'
    Then a 200 should be returned
    

  Scenario: Clearning a request
    Given I run
    """
    Mirage::Client.new.clear :request => 1
    """
    When I send GET to 'http://localhost:7001/mirage/requests/1'
    Then a 404 should be returned
    When I send GET to 'http://localhost:7001/mirage/responses/greeting'
    Then a 200 should be returned
    When I send GET to 'http://localhost:7001/mirage/responses/leaving'
    Then a 200 should be returned
    When I send GET to 'http://localhost:7001/mirage/requests/2'
    Then a 200 should be returned





