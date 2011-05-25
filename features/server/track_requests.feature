Feature: After a response has been served from Mirage, the content of the request that triggered it can be retrieved. This is useful
  for testing that the correct information was sent to the endpoint.

  On setting a response, a unique id is returned which can be used to look up the last request made to get that response.

  If the the response is reset then the same id is returned in order to make it easier to keep track of.

  Responses hosted on the same endpoint but with a pattern are considered unique and so get their own ID.

  If the request body contains content this is stored. Otherwise it is the query string that is stored.

  If a response is 'peeked' this does not count as a request that should be stored.

  Background: There is a response already on Mirage
    Given I send PUT to 'http://localhost:7001/mirage/templates/greeting' with body 'Hello' and headers:
      | X-mirage-method | POST |


  Scenario: Tracking a response that was triggered by a request that had content in the body
    Given I send POST to 'http://localhost:7001/mirage/responses/greeting' with request entity
    """
    Hello Mirage
    """
    When I send GET to 'http://localhost:7001/mirage/requests/1'
    Then 'Hello Mirage' should be returned


  Scenario: Tracking a response that was triggered by a request with a query string
    Given I send POST to 'http://localhost:7001/mirage/responses/greeting' with parameters:
      | surname   | Davis |
      | firstname | Leon  |
    When I send GET to 'http://localhost:7001/mirage/requests/1'
    Then 'surname=Davis&firstname=Leon' should be returned


  Scenario: Tracking a response that has not been served yet
    Given I hit 'http://localhost:7001/mirage/requests/1'
    Then a 404 should be returned



  Scenario: A response is peeked at
    Given I send POST to 'http://localhost:7001/mirage/responses/greeting' with request entity
    """
    Hello
    """
    And I send GET to 'http://localhost:7001/mirage/templates/1'
    When I send GET to 'http://localhost:7001/mirage/requests/1'
    Then 'Hello' should be returned


  Scenario: A default response and one for the same endpoint with a pattern are set
    Given I send PUT to 'http://localhost:7001/mirage/templates/greeting' with body 'Hello who ever you are'
    Then '2' should be returned

    Given I send PUT to 'http://localhost:7001/mirage/templates/greeting' with body 'Hello' and headers:
      | X-mirage-pattern | Leon |
    Then '3' should be returned

    When I send GET to 'http://localhost:7001/mirage/responses/greeting' with parameters:
      | name | Joel |
    And I send GET to 'http://localhost:7001/mirage/responses/greeting' with parameters:
      | name | Leon |

    And I send GET to 'http://localhost:7001/mirage/requests/2'
    Then 'name=Joel' should be returned

    And I send GET to 'http://localhost:7001/mirage/requests/3'
    Then 'name=Leon' should be returned


