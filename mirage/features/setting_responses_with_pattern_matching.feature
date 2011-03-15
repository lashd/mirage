Feature: The MockServer can be configured to return particular responses conditionally based on a pattern in the
  querystring or the body of a request.

  Background: There is already a default response for 'greeting'
    Given I hit 'http://localhost:7001/mirage/set/greeting' with parameters:
      | response | Hello Stranger. |


  Scenario: A plain text pattern found in the request body
    Given I hit 'http://localhost:7001/mirage/set/greeting' with parameters:
      | response | Hello Leon, how are you? |
      | pattern  | <name>leon</name>        |
    When I hit 'http://localhost:7001/mirage/get/greeting' with request body:
    """
     <greetingRequest>
      <name>leon</name>
     </greetingRequest>
    """
    Then 'Hello Leon, how are you?' should be returned

  Scenario: A regex based pattern found in the request body
    Given the response for 'greeting' with pattern '.*?leon<\/name>' is:
    """
    Hello Leon, how are you?
    """
    When I hit 'http://localhost:7001/mirage/get/greeting' with request body:
    """
     <greetingRequest>
      <name>leon</name>
     </greetingRequest>
    """
    Then 'Hello Leon, how are you?' should be returned


  Scenario: A plain text pattern found in the query string
    Given the response for 'greeting' with pattern 'leon' is:
    """
    Hello Leon, how are you?
    """
    When getting 'greeting' with request parameters:
      | parameter | value |
      | name      | leon  |
    Then 'Hello Leon, how are you?' should be returned


  Scenario:  A regex based pattern found in the query string
    Given the response for 'greeting' with pattern 'name=[L|l]eon' is:
    """
    Hello Leon, how are you?
    """
    When getting 'greeting' with request parameters:
      | parameter | value |
      | name      | leon  |
    Then 'Hello Leon, how are you?' should be returned

  Scenario: Pattern not matched
    Given the response for 'greeting' with pattern '.*?leon<\/name>' is:
    """
    Hello Leon, how are you?
    """
    When I hit 'http://localhost:7001/mirage/get/greeting' with request body:
    """
     <greetingRequest>
      <name>jim</name>
     </greetingRequest>
    """
    Then 'Hello Stranger.' should be returned