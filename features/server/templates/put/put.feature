Feature: Mirage can be configured with templates that are returned when addressed from ${mirage_url}/responses
  On setting a template, a unique id is retuned. This is a key that can be used to manage the template. 
  
  Templates can be configured to respond to either, GET, POST, PUT, or DELETE. If you put more than one template to the same address
  but configure them to respond to different HTTP methods, then they are held as seperate resources and are assigned different ids.

  Templates can have following attributes configured by setting the following HTTP headers:
  X-mirage-pattern (optional) = criteria for when a response should be returned. see put_with_pattern.feature
  X-mirage-delay (optional) = the amount of time in seconds that mirage should wait for before responding (defaults to 0)
  X-mirage-method (optional) = http method that this response applies to. Can be set to GET, POST, PUT or DELETE. Templates are configured to respond to GET requests by default
  X-mirage-default (optional) = set whether the reponse can act as a default response, see put_as_default.feature (defaults to false)
  X-mirage-status-code (optional) = set the http status that is returned, defaults to 200
  content-type (optional) = Set the content type to be returned


  Scenario: A template without any selection criteria
    Given I send PUT to 'http://localhost:7001/mirage/templates/greeting' with body 'Hello'

    When I send GET to 'http://localhost:7001/mirage/responses/greeting'
    Then 'Hello' should be returned
    And a 200 should be returned
    

  Scenario: A template put under a deeper address
    Given I send PUT to 'http://localhost:7001/mirage/templates/say/hello/to/me' with body 'Hello to me'

    When I send GET to 'http://localhost:7001/mirage/responses/say/hello/to/me'
    Then 'Hello to me' should be returned
    

  Scenario: Setting the content-type header
    Given I send PUT to 'http://localhost:7001/mirage/templates/say/hello/to/me' with body '<xml></xml>' and headers:
    |content-type|text/xml|

    When I send GET to 'http://localhost:7001/mirage/responses/say/hello/to/me'
    Then '<xml></xml>' should be returned
    And the response 'content-type' should be 'text/xml'


  Scenario: Putting a template to the same resource
    Given I send PUT to 'http://localhost:7001/mirage/templates/greeting' with body 'Hello'
    Then '1' should be returned

    Given I send PUT to 'http://localhost:7001/mirage/templates/greeting' with body 'Hi'
    Then '1' should be returned

  Scenario: Setting the http status code to be returned
    Given I send PUT to 'http://localhost:7001/mirage/templates/greeting' with body 'Hello' and headers:
      | X-mirage-status-code | 202 |
    When I send GET to 'http://localhost:7001/mirage/responses/greeting'
    Then a 202 should be returned
    
    


  Scenario Outline: Templates is configured to respond to different http methods
    Given I send PUT to 'http://localhost:7001/mirage/templates/greeting' with body 'GET' and headers:
      | X-mirage-method | GET |
    And '1' should be returned
    
    Given I send PUT to 'http://localhost:7001/mirage/templates/greeting' with body 'POST' and headers:
      | X-mirage-method | POST |
    And '2' should be returned
    
    Given I send PUT to 'http://localhost:7001/mirage/templates/greeting' with body 'DELETE' and headers:
      | X-mirage-method | DELETE |
    And '3' should be returned
    
    Given I send PUT to 'http://localhost:7001/mirage/templates/greeting' with body 'PUT' and headers:
      | X-mirage-method | PUT |
    And '4' should be returned
    
    When I send <method> to 'http://localhost:7001/mirage/responses/greeting'
    Then '<method>' should be returned
  Examples:
    | method |
    | GET    |
    | POST   |
    | PUT    |
    | DELETE |


  Scenario: Getting a response for a template resources that does not exist
    When I send GET to 'http://localhost:7001/mirage/responses/response_that_does_not_exist'
    Then a 404 should be returned
