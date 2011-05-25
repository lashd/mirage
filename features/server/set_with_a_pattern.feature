Feature: Mirage can be configured to return particular responses conditionally based on if a prescribed pattern is found in
  querystring or the body of a request.

  Patterns can be either plain text or a regular expression

  Background: There is already a default response for 'greeting'
    Given I send PUT to 'http://localhost:7001/mirage/templates/greeting' with body 'Hello Stranger' and headers:
      | X-mirage-method | POST |

  Scenario: A plain text pattern found in the request body

    Given I send PUT to 'http://localhost:7001/mirage/templates/greeting' with body 'Hello Leon, how are you?' and headers:
      | X-mirage-pattern | <name>leon</name> |
      | X-mirage-method  | POST              |
    When I send POST to 'http://localhost:7001/mirage/responses/greeting' with request entity
    """
     <greetingRequest>
      <name>leon</name>
     </greetingRequest>
    """
    Then 'Hello Leon, how are you?' should be returned


  Scenario: A regex based pattern found in the request body
    Given I send PUT to 'http://localhost:7001/mirage/templates/greeting' with body 'Hello Leon, how are you?' and headers:
      | X-mirage-pattern | .*?leon<\/name> |
      | X-mirage-method  | POST            |
    When I send POST to 'http://localhost:7001/mirage/responses/greeting' with request entity
    """
     <greetingRequest>
      <name>leon</name>
     </greetingRequest>
    """
    Then 'Hello Leon, how are you?' should be returned


  Scenario: A plain text pattern found in the query string
    Given I send PUT to 'http://localhost:7001/mirage/templates/greeting' with body 'Hello Leon, how are you?' and headers:
      | X-mirage-pattern | leon |
      | X-mirage-method  | POST |
    When I send POST to 'http://localhost:7001/mirage/responses/greeting' with parameters:
      | name | leon |
    Then 'Hello Leon, how are you?' should be returned


  Scenario:  A regex based pattern found in the query string
    Given I send PUT to 'http://localhost:7001/mirage/templates/greeting' with body 'Hello Leon, how are you?' and headers:
      | X-mirage-pattern | name=[L\|l]eon |
      | X-mirage-method  | POST           |
    When I send POST to 'http://localhost:7001/mirage/responses/greeting' with parameters:
      | name | leon |

    Then 'Hello Leon, how are you?' should be returned


  Scenario: The pattern is not matched
    Given I send PUT to 'http://localhost:7001/mirage/templates/greeting' with body 'Hello Leon, how are you?' and headers:
      | X-mirage-pattern | .*?leon<\/name> |
      | X-mirage-method  | POST            |
    When I send POST to 'http://localhost:7001/mirage/responses/greeting' with request entity
    """
     <greetingRequest>
      <name>jim</name>
     </greetingRequest>
    """

    Then 'Hello Stranger' should be returned