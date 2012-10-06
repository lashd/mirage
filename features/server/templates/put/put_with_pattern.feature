Feature: Mirage can be configured to return particular responses conditionally based on if a prescribed pattern is found in
  querystring or the body of a request.

  Patterns can be either plain text or a regular expression

  A response with a pattern is not considered the same a response at the same address that has either no pattern or a different one.
  This allows you to specify different behaviour depending on the request.

  Background: There is already a default response for 'greeting'
    Given I send PUT to 'http://localhost:7001/mirage/templates/greeting' with body 'Hello Stranger' and headers:
      | X-mirage-method | POST |

  Scenario: A plain text pattern found in the request body

    Given I send PUT to 'http://localhost:7001/mirage/templates/greeting' with body 'Hello Leon, how are you?' and headers:
      | x-mirage-required_body_content1 | %r{.*eon} |
      | X-mirage-method                 | POST      |
    When I send POST to 'http://localhost:7001/mirage/responses/greeting' with request entity
    """
     <greetingRequest>
      <name>leon</name>
     </greetingRequest>
    """
    Then 'Hello Leon, how are you?' should be returned


  Scenario: Matching multiple request parameters
    Given I send PUT to 'http://localhost:7001/mirage/templates/greeting' with body 'Hello Leon, how are you?' and headers:
      | x-mirage-required_parameter1 | firstname:leon    |
      | x-mirage-required_parameter2 | surname:%r{davis} |
    When I send GET to 'http://localhost:7001/mirage/responses/greeting' with parameters:
      | surname   | davis |
      | firstname | leon  |
    Then 'Hello Leon, how are you?' should be returned


  Scenario: The pattern is not matched
    Given I send PUT to 'http://localhost:7001/mirage/templates/greeting' with body 'Hello Leon, how are you?' and headers:
      | x-mirage-required_parameter1 | firstname:leon |
      | X-mirage-method              | POST           |
    When I send POST to 'http://localhost:7001/mirage/responses/greeting' with request entity
    """
     <greetingRequest>
      <name>jim</name>
     </greetingRequest>
    """
    Then 'Hello Stranger' should be returned

  Scenario: Templates with different patterns on the same address
    When I send PUT to 'http://localhost:7001/mirage/templates/greeting' with body 'Hello Leon, how are you?' and headers:
      | x-mirage-required_parameter1 | firstname:leon |

    When I send PUT to 'http://localhost:7001/mirage/templates/greeting' with body 'Hello Leon, how are you?' and headers:
      | x-mirage-required_parameter1 | firstname:leon |
    Then '2' should be returned
    
      