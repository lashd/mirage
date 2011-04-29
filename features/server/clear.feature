Feature: Responses and requests can be cleared.
  Clearing a response clears any associated request information that may have been stored.

  Usage:
  ${mirage_url}/clear - Clear all responses and requests
  ${mirage_url}/clear/requests - Clear all requests
  ${mirage_url}/clear/response_id - Clear a requests and response for a particular response
  ${mirage_url}/clear/request/response_id - Clear request for a particular response



  Background: The MockServer has already got a response for greeting and leaving on it.
    Given I send PUT to 'http://localhost:7001/mirage/responses/greeting' with request entity
      """
      {"response" : "Hello"}
      """

    And I send PUT to 'http://localhost:7001/mirage/responses/leaving' with request entity
      """
      {"response" : "Goodbye"}
      """



  Scenario: Clearing all responses
    Given I send DELETE to 'http://localhost:7001/mirage/responses'

    When I send GET to 'http://localhost:7001/mirage/responses/greeting.replay'
    Then a 404 should be returned

    When I send GET to 'http://localhost:7001/mirage/responses/leaving.replay'
    Then a 404 should be returned


  Scenario: Clearing a particular response
    Given I send DELETE to 'http://localhost:7001/mirage/responses/1'

    When I send GET to 'http://localhost:7001/mirage/responses/greeting.replay'
    Then a 404 should be returned

    When I send GET to 'http://localhost:7001/mirage/responses/leaving.replay'
    Then 'Goodbye' should be returned
    
    #TODO - fix this
    When I hit 'http://localhost:7001/mirage/check/1'
    Then a 404 should be returned

    


    #TODO you are here
  Scenario: Clearing all requests
    Given I hit 'http://localhost:7001/mirage/get/greeting' with request body:
    """
    Say 'Hello' to me
    """
    And I hit 'http://localhost:7001/mirage/get/leaving' with request body:
    """
    Say 'Goodbye' to me
    """
    And I hit 'http://localhost:7001/mirage/clear/'

    When I hit 'http://localhost:7001/mirage/check/1'
    Then a 404 should be returned

    When I hit 'http://localhost:7001/mirage/check/2'
    Then a 404 should be returned


  Scenario: Clearing a stored request request for a prticular response
    Given I hit 'http://localhost:7001/mirage/get/leaving' with request body:
    """
    See you later
    """

    When I hit 'http://localhost:7001/mirage/clear/request/2'
    Then I hit 'http://localhost:7001/mirage/check/2'
    And a 404 should be returned


    Scenario: Querying a response that has been cleared
    Given I hit 'http://localhost:7001/mirage/get/greeting' with request body:
    """
    greet me :)
    """
    And I hit 'http://localhost:7001/mirage/clear/1'

    When I hit 'http://localhost:7001/mirage/check/1'
    Then a 404 should be returned