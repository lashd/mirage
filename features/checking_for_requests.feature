Feature: After a response has been served from Mirage, the content of the request that triggered it can be retrieved. This is useful
  for testing that the correct information was sent to the endpoint.

  On setting a response, a unique id is returned which can be used to look up the last request made to get that response.

  If the the response is reset then the same id is returned in order to make it easier to keep track of.

  Responses hosted on the same endpoint but with a pattern are considered unique and so get their own ID.

  If the request body contains content this is stored. Otherwise it is the query string that is stored.
  
  If a response is 'peeked' this does not count as a request that should be stored.

  Background: There is a response already on Mirage
    Given I hit 'http://localhost:7001/mirage/set/greeting' with parameters:
      | response | Hello |


  Scenario: Querying a response that was triggered by a request that had content in the body
    Given I hit 'http://localhost:7001/mirage/get/greeting' with request body:
    """
    Hello MockServer
    """
    When I hit 'http://localhost:7001/mirage/check_request/1'
    Then 'Hello MockServer' should be returned


  Scenario: Querying a response that was triggered by a request with a query string
    Given I hit 'http://localhost:7001/mirage/get/greeting' with parameters:
      | surname   | Davis |
      | firstname | Leon  |
    When I hit 'http://localhost:7001/mirage/check_request/1'
    Then 'surname=Davis&firstname=Leon' should be returned


  Scenario: Querying a response that has not been served yet
    Given I hit 'http://localhost:7001/mirage/check_request/1'
    Then a 404 should be returned


  Scenario: A response is peeked at
    Given I hit 'http://localhost:7001/mirage/get/greeting' with request body:
    """
    Hello
    """
    And I hit 'http://localhost:7001/mirage/peek/1'
    When I hit 'http://localhost:7001/mirage/check_request/1'
    Then 'Hello' should be returned


  Scenario: A default response and one for the same endpoint with a pattern are set
    When I hit 'http://localhost:7001/mirage/set/greeting' with parameters:
      | response | Hello who ever you are |
    Then '1' should be returned

    When I hit 'http://localhost:7001/mirage/set/greeting' with parameters:
      | response | Hello Leon |
      | pattern  | Leon       |
    Then '3' should be returned

    When I hit 'http://localhost:7001/mirage/get/greeting' with request body:
    """
    My name is Joel
    """
    And I hit 'http://localhost:7001/mirage/get/greeting' with request body:
    """
    My name is Leon
    """
    And I hit 'http://localhost:7001/mirage/check_request/1'
    Then 'My name is Joel' should be returned
    And I hit 'http://localhost:7001/mirage/check_request/3'
    Then 'My name is Leon' should be returned


