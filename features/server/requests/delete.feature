Feature: Request data can be deleted. 

  Background: The MockServer has already got a response for greeting and leaving on it.
    Given I send PUT to 'http://localhost:7001/mirage/templates/greeting' with body 'Hello'
    And I send GET to 'http://localhost:7001/mirage/responses/greeting'

    And I send PUT to 'http://localhost:7001/mirage/templates/leaving' with body 'Goodbye'
    And I send GET to 'http://localhost:7001/mirage/responses/leaving'

    
  Scenario: Deleting all requests
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


  Scenario: Deleting a stored request for a prticular response
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