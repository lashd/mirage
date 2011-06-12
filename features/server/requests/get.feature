Feature: After a response has been served from Mirage, the content of the request that triggered it can be retrieved. This is useful
  for testing that the correct information was sent to the endpoint.

  On putting a respons template on to Mirage, a unique id is returned which can be used to look up the last request made to get that response.

  If the request body contains content this is stored. Otherwise it is the query string that is stored.

  Background: A template has already be put on Mirage
    Given I send PUT to 'http://localhost:7001/mirage/templates/greeting' with body 'Hello' and headers:
      | X-mirage-method | POST |


  Scenario: Getting request data when the data was in the body.
    Given I send POST to 'http://localhost:7001/mirage/responses/greeting' with request entity
    """
    Hello Mirage
    """
    When I send GET to 'http://localhost:7001/mirage/requests/1'
    Then 'Hello Mirage' should be returned


  Scenario: Getting request data when the data was in the query string.
    Given I send POST to 'http://localhost:7001/mirage/responses/greeting' with parameters:
      | surname   | Davis |
      | firstname | Leon  |
    When I send GET to 'http://localhost:7001/mirage/requests/1'
    Then 'surname=Davis&firstname=Leon' should be returned


  Scenario: Getting request data for a template that has not been served yet.
    Given I send GET to 'http://localhost:7001/mirage/requests/1'
    Then a 404 should be returned