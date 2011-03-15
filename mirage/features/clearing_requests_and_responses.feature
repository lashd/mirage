Feature: Once responses and requests are on the MockServer they can be cleared.
  Clearing a response clears its requests.

  Usage:
  ${mirage_url}/clear - Clear all responses and requests
  ${mirage_url}/clear/requests - Clear all requests
  ${mirage_url}/clear/response_id - Clear a requests and response for a particular response
  ${mirage_url}/clear/request/response_id - Clear request for a particular response


  Background: The MockServer has already got a response for greeting and leaving on it.
    Given I hit 'http://localhost:7001/mirage/set/greeting' with parameters:
      | response | Hello |

    And I hit 'http://localhost:7001/mirage/set/leaving' with parameters:
      | response | Goodbye |


  Scenario: Clearing all responses
    When I hit 'http://localhost:7001/mirage/clear'
    And I hit 'http://localhost:7001/mirage/get/greeting'
    Then a 404 should be returned
    And I hit 'http://localhost:7001/mirage/get/leaving'
    Then a 404 should be returned

  Scenario: clearing a particular response set
    When I hit 'http://localhost:7001/mirage/clear/1'
    And I hit 'http://localhost:7001/mirage/get/greeting'
    Then a 404 should be returned

    When I hit 'http://localhost:7001/mirage/check/1'
    Then a 404 should be returned

    When I hit 'http://localhost:7001/mirage/get/leaving'
    Then 'Goodbye' should be returned


  Scenario: Check request for a response that has been cleared
    When I hit 'http://localhost:7001/mirage/get/greeting' with request body:
    """
    greet me :)
    """
    And I hit 'http://localhost:7001/mirage/clear/1'
    Then I hit 'http://localhost:7001/mirage/check/1'
    Then a 404 should be returned


  Scenario: clearing requests
    And I hit 'http://localhost:7001/mirage/get/greeting' with request body:
    """
    Say 'Hello' to me
    """
    And I hit 'http://localhost:7001/mirage/get/leaving' with request body:
    """
    Say 'Goodbye' to me
    """
    When I hit 'http://localhost:7001/mirage/clear'
    Then I hit 'http://localhost:7001/mirage/check/1'
    Then a 404 should be returned
    Then I hit 'http://localhost:7001/mirage/check/2'
    Then a 404 should be returned


  Scenario: clearing a particular request set
    Given I hit 'http://localhost:7001/mirage/get/leaving' with request body:
    """
    See you later
    """
    When I hit 'http://localhost:7001/mirage/clear/request/2'
    Then I hit 'http://localhost:7001/mirage/check/2'
    Then a 404 should be returned