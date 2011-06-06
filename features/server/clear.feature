Feature: Responses and requests can be cleared.
  Clearing a response clears any associated request information that may have been stored.

  Usage:
  ${mirage_url}/clear - Clear all responses and requests
  ${mirage_url}/clear/requests - Clear all requests
  ${mirage_url}/clear/response_id - Clear a requests and response for a particular response
  ${mirage_url}/clear/request/response_id - Clear request for a particular response


  Background: The MockServer has already got a response for greeting and leaving on it.
    Given I send PUT to 'http://localhost:7001/mirage/templates/greeting' with body 'Hello'
    And I send GET to 'http://localhost:7001/mirage/responses/greeting'

    And I send PUT to 'http://localhost:7001/mirage/templates/leaving' with body 'Goodbye'
    And I send GET to 'http://localhost:7001/mirage/responses/leaving'


  Scenario: Clearing all responses
    Given I send DELETE to 'http://localhost:7001/mirage/templates'

    When I send GET to 'http://localhost:7001/mirage/requests/1'
    Then a 404 should be returned
    When I send GET to 'http://localhost:7001/mirage/responses/greeting'
    Then a 404 should be returned
    When I send GET to 'http://localhost:7001/mirage/templates/1'
    Then a 404 should be returned

    When I send GET to 'http://localhost:7001/mirage/requests/2'
    Then a 404 should be returned
    When I send GET to 'http://localhost:7001/mirage/responses/leaving'
    Then a 404 should be returned
    When I send GET to 'http://localhost:7001/mirage/templates/2'
    Then a 404 should be returned


  Scenario: Clearing a particular response
    Given I send DELETE to 'http://localhost:7001/mirage/templates/1'

    When I send GET to 'http://localhost:7001/mirage/templates/1'
    Then a 404 should be returned
    When I send GET to 'http://localhost:7001/mirage/responses/greeting'
    Then a 404 should be returned
    When I send GET to 'http://localhost:7001/mirage/requests/1'
    Then a 404 should be returned

    When I send GET to 'http://localhost:7001/mirage/requests/2'
    Then a 200 should be returned
    When I send GET to 'http://localhost:7001/mirage/responses/leaving'
    Then a 200 should be returned
    When I send GET to 'http://localhost:7001/mirage/templates/2'
    Then a 200 should be returned
    


  Scenario: Clearing all requests
    And I send DELETE to 'http://localhost:7001/mirage/requests'

    When I send GET to 'http://localhost:7001/mirage/requests/1'
    Then a 404 should be returned
    When I send GET to 'http://localhost:7001/mirage/responses/greeting'
    Then a 200 should be returned
    When I send GET to 'http://localhost:7001/mirage/templates/1'
    Then a 200 should be returned
    

    When I send GET to 'http://localhost:7001/mirage/requests/2'
    Then a 404 should be returned
    When I send GET to 'http://localhost:7001/mirage/responses/leaving'
    Then a 200 should be returned
    When I send GET to 'http://localhost:7001/mirage/templates/2'
    Then a 200 should be returned
    


  Scenario: Clearing a stored request for a prticular response
    And I send DELETE to 'http://localhost:7001/mirage/requests/1'
    
    When I send GET to 'http://localhost:7001/mirage/requests/1'
    Then a 404 should be returned
    When I send GET to 'http://localhost:7001/mirage/responses/greeting'
    Then a 200 should be returned
    When I send GET to 'http://localhost:7001/mirage/templates/1'
    Then a 200 should be returned
    

    When I send GET to 'http://localhost:7001/mirage/requests/2'
    Then a 200 should be returned
    When I send GET to 'http://localhost:7001/mirage/responses/leaving'
    Then a 200 should be returned
    When I send GET to 'http://localhost:7001/mirage/templates/2'
    Then a 200 should be returned
    