Feature: Mirage can be configured with responses to be returned with the correct end point is hit.
  On setting a response, a unique id is retuned. This is a key that can be used to manage the response. E.g. clearing or peek at it.

  Usage:
  HTTP METHOD: PUT -> /mirage/responses/your/response
  Content type -> application/json

  content:
  response (mandatatory) = your response
  pattern (optional) = criteria for when a response should be returned. see set_with_a_pattern.feature
  delay (optional) = the amount of time in seconds that mirage should wait for before responding (defaults to 0)
  method (optional) = http method that this response applies to. (defaults to get if not supplied)
  default (optional) = set whether the reponse can act as a default response, see set_default_response.feature (defaults to false)


  Scenario: Setting a response without any selection criteria
    Given I send PUT to 'http://localhost:7001/mirage/responses/greeting' with request entity
    """
    { "response" : "Hello, how are you?" }
    """

    When I send GET to 'http://localhost:7001/mirage/responses/greeting.replay'
    Then 'Hello, how are you?' should be returned

  Scenario: A response hosted on a longer url
    Given I send PUT to 'http://localhost:7001/mirage/responses/say/hello/to/me' with request entity
    """
    { "response" : "Hello to me" }
    """
    When I send GET to 'http://localhost:7001/mirage/responses/say/hello/to/me.replay'
    Then 'Hello to me' should be returned


  Scenario: The same endpoint is set more than once
    Given I send PUT to 'http://localhost:7001/mirage/responses/greeting' with request entity
    """
    { "response" : "Hello" }
    """
    Then '1' should be returned

    Given I send PUT to 'http://localhost:7001/mirage/responses/greeting' with request entity
    """
    { "response" : "Hi" }
    """
    Then '1' should be returned


  Scenario Outline: Response set to respond to different http methods
    Given I send PUT to 'http://localhost:7001/mirage/responses/greeting' with request entity
    """
    { "response" : "GET", "method" : "GET" }
    """
    Given I send PUT to 'http://localhost:7001/mirage/responses/greeting' with request entity
    """
    { "response" : "POST", "method" : "POST" }
    """
    Given I send PUT to 'http://localhost:7001/mirage/responses/greeting' with request entity
    """
    { "response" : "DELETE", "method" : "DELETE" }
    """
    Given I send PUT to 'http://localhost:7001/mirage/responses/greeting' with request entity
    """
    { "response" : "PUT", "method" : "PUT" }
    """
    When I send <method> to 'http://localhost:7001/mirage/responses/greeting.replay'
    Then '<method>' should be returned
  Examples:
    | method |
    | GET    |
    | POST   |
    | PUT    |
    | DELETE |


  Scenario: A response is not supplied
    Given I send PUT to 'http://localhost:7001/mirage/responses/greeting'
    Then a 500 should be returned


  Scenario: Getting a response that does not exist
    When I send GET to 'http://localhost:7001/mirage/responses/response_that_does_not_exist.replay'
    Then a 404 should be returned
