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
  content-type = Set the content type to be returned


  Scenario: Setting a response without any selection criteria
    Given I send PUT to 'http://localhost:7001/mirage/templates/greeting' with body 'Hello'

    When I send GET to 'http://localhost:7001/mirage/responses/greeting'
    Then 'Hello' should be returned

  Scenario: A response hosted on a longer url
    Given I send PUT to 'http://localhost:7001/mirage/templates/say/hello/to/me' with body 'Hello to me'

    When I send GET to 'http://localhost:7001/mirage/responses/say/hello/to/me'
    Then 'Hello to me' should be returned

  Scenario: Content type is set
    Given I send PUT to 'http://localhost:7001/mirage/templates/say/hello/to/me' with body '<xml></xml>' and headers:
    |content-type|text/xml|

    When I send GET to 'http://localhost:7001/mirage/responses/say/hello/to/me'
    Then '<xml></xml>' should be returned
    And the response 'content-type' should be 'text/xml'


  Scenario: The same endpoint is set more than once
    Given I send PUT to 'http://localhost:7001/mirage/templates/greeting' with body 'Hello'
    Then '1' should be returned

    Given I send PUT to 'http://localhost:7001/mirage/templates/greeting' with body 'Hi'
    Then '1' should be returned


  Scenario Outline: Response set to respond to different http methods
    Given I send PUT to 'http://localhost:7001/mirage/templates/greeting' with body 'GET' and headers:
      | X-mirage-method | GET |
    Given I send PUT to 'http://localhost:7001/mirage/templates/greeting' with body 'POST' and headers:
      | X-mirage-method | POST |
    Given I send PUT to 'http://localhost:7001/mirage/templates/greeting' with body 'DELETE' and headers:
      | X-mirage-method | DELETE |
    Given I send PUT to 'http://localhost:7001/mirage/templates/greeting' with body 'PUT' and headers:
      | X-mirage-method | PUT |
    When I send <method> to 'http://localhost:7001/mirage/responses/greeting'
    Then '<method>' should be returned
  Examples:
    | method |
    | GET    |
    | POST   |
    | PUT    |
    | DELETE |


  Scenario: Getting a response that does not exist
    When I send GET to 'http://localhost:7001/mirage/responses/response_that_does_not_exist'
    Then a 404 should be returned
