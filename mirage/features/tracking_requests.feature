Feature: After a response has been served from the MockServer, the content of the request triggered it can be retrieved which
  is useful for testing that the correct information was sent to the endpint that the MockServer is stubbing,

  On setting a response on the MockServer a unique id is returned which can be used to look up the last request made to
  get that response. If the the response is reset then the same id is returned in order to make it easier to keep track of.

  Responses hosted on the same endpoint but with a pattern are considered unique and so get their own ID.

  If there is content in the request body because something like a web service is called the request body content is returned.
  If there is nothing in the request body then the query string is returned.


  Scenario: The MockServer returns a response
    Given the response for 'greeting' is:
    """
    Hello
    """
    When getting 'greeting' with request body:
    """
    Hello MockServer
    """
    Then 'Hello MockServer' should have been tracked

    When getting 'greeting' with request parameters:
      | parameter | value |
      | firstname | Leon  |
      | surname   | Davis |
    Then 'firstname=Leon&surname=Davis' should have been tracked


  Scenario: The MockServer has not responsed
    Given the response for 'greeting' is:
    """
    Hello
    """
    Then tracking the request should return a 404


  Scenario: A response is peeked at
    Given the response for 'greeting' is:
    """
    Hello
    """
    When getting 'greeting' with request body:
    """
    Hello MockServer
    """
    And peeking at the response for response id '(.*?)'
    Then 'Hello MockServer' should have been tracked


  Scenario: The same endpoint is set more than once
    Given the response for 'greeting' is:
    """
    Hello
    """
    Then the response id should be '1'
    Given the response for 'greeting' is:
    """
    Hi
    """
    Then the response id should be '1'



  Scenario: A default response and one for the same endpoint with but with a pattern is added to the MockServer
    Given the response for 'greeting' is:
    """
    Hello who ever you are
    """
    And the response id should be '1'
    And the response for 'greeting' with pattern 'Leon' is:
    """
    Hello Leon
    """
    And the response id should be '2'
    When getting 'greeting' with request body:
    """
    My name is Joel
    """
    And getting 'greeting' with request body:
    """
    My name is Leon
    """
    Then 'My name is Joel' should have been tracked for response id '1'
    Then 'My name is Leon' should have been tracked for response id '2'


