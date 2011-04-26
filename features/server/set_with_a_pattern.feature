Feature: Mirage can be configured to return particular responses conditionally based on if a prescribed pattern is found in
  querystring or the body of a request.

  Patterns can be either plain text or a regular expression

  Background: There is already a default response for 'greeting'
    Given I send PUT to 'http://localhost:7001/mirage/greeting' with request entity
    """
    { "response" : "Hello Stranger." }
    """

  Scenario: A plain text pattern found in the request body
    Given I send PUT to 'http://localhost:7001/mirage/greeting' with request entity
    """
    { "response" : "Hello Leon, how are you?", "pattern" : "<name>leon</name>" }
    """
    When I send POST to 'http://localhost:7001/mirage/get/greeting' with request entity
    """
     <greetingRequest>
      <name>leon</name>
     </greetingRequest>
    """
    Then 'Hello Leon, how are you?' should be returned


  Scenario: A regex based pattern found in the request body
    Given I send PUT to 'http://localhost:7001/mirage/greeting' with request entity
    """
    { "response" : "Hello Leon, how are you?", "pattern" : ".*?leon<\/name>" }
    """

    When I send POST to 'http://localhost:7001/mirage/get/greeting' with request entity
    """
     <greetingRequest>
      <name>leon</name>
     </greetingRequest>
    """
    Then 'Hello Leon, how are you?' should be returned


  Scenario: A plain text pattern found in the query string
    Given I send PUT to 'http://localhost:7001/mirage/greeting' with request entity
    """
    { "response" : "Hello Leon, how are you?", "pattern" : "leon" }
    """

    When I send POST to 'http://localhost:7001/mirage/get/greeting' with parameters:
      | name | leon |

    Then 'Hello Leon, how are you?' should be returned


  Scenario:  A regex based pattern found in the query string
    Given I send PUT to 'http://localhost:7001/mirage/greeting' with request entity
    """
    { "response" : "Hello Leon, how are you?", "pattern" : "name=[L\|l]eon" }
    """
    When I send POST to 'http://localhost:7001/mirage/get/greeting' with parameters:
      | name | leon |

    Then 'Hello Leon, how are you?' should be returned


  Scenario: The pattern is not matched
    Given I send PUT to 'http://localhost:7001/mirage/greeting' with request entity
    """
    { "response" : "Hello Leon, how are you?", "pattern" : ".*?leon<\/name>" }
    """

    When I send POST to 'http://localhost:7001/mirage/get/greeting' with request entity
    """
     <greetingRequest>
      <name>jim</name>
     </greetingRequest>
    """

    Then 'Hello Stranger.' should be returned