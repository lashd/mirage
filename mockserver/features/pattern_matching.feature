Feature: The MockServer can be configured to return particular responses conditionally based on a pattern in the
  querystring or the body of a request.

  Background: There is already a default response for 'greeting'
    Given the response for 'greeting'
    """
    Hello Stranger.
    """

  Scenario: A plain text pattern found in the request body
    Given a response for 'greeting' with pattern '<name>leon</name>'
    """
    Hello Leon, how are you?
    """
    When getting 'greeting' with request body:
    """
     <greetingRequest>
      <name>leon</name>
     </greetingRequest>
    """
    Then the response should be 'Hello Leon, how are you?'

  Scenario: A regex based pattern found in the request body
    Given a response for 'greeting' with pattern '.*?leon<\/name>'
    """
    Hello Leon, how are you?
    """
    When getting 'greeting' with request body:
    """
     <greetingRequest>
      <name>leon</name>
     </greetingRequest>
    """
    Then the response should be 'Hello Leon, how are you?'


  Scenario: A plain text pattern found in the query string
    Given a response for 'greeting' with pattern 'leon'
    """
    Hello Leon, how are you?
    """
    When getting 'greeting' with query string:
      | parameter | value |
      | name      | leon  |
    Then the response should be 'Hello Leon, how are you?'


  Scenario:  A regex based pattern found in the query string
    Given a response for 'greeting' with pattern 'name=[L|l]eon'
    """
    Hello Leon, how are you?
    """
    When getting 'greeting' with query string:
      | parameter | value |
      | name      | leon  |
    Then the response should be 'Hello Leon, how are you?'

  Scenario: Pattern not matched
    Given a response for 'greeting' with pattern '.*?leon<\/name>'
    """
    Hello Leon, how are you?
    """
    When getting 'greeting' with request body:
    """
     <greetingRequest>
      <name>jim</name>
     </greetingRequest>
    """
    Then the response should be 'Hello Stranger.'