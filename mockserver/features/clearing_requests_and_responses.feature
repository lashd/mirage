Feature: Once responses and requests are on the MockServer they can be cleared.

  Background: The MockServer has already got a response for greeting and leaving on it
    Given the response for 'greeting' is:
    """
    Hello
    """
    And the response for 'leaving' is:
    """
    Goodbye
    """

  Scenario: Clearing all responses
    When I clear 'all' responses from the MockServer
    And getting 'greeting'
    Then a 404 should be returned
    And getting 'leaving'
    Then a 404 should be returned

  Scenario: clearing a particular response set
    When I clear 'greeting' responses from the MockServer
    And getting 'greeting'
    Then a 404 should be returned
    And getting 'leaving'
    Then 'Goodbye' should be returned

  Scenario: clearing requests
    And getting 'greeting' with request body:
    """
    Say 'Hello' to me
    """
    And getting 'leaving' with request body:
    """
    Say 'Goodbye' to me
    """
    When I clear 'all' requests from the MockServer
    Then tracking the last request for 'greeting' should return a 404
    Then tracking the last request for 'leaving' should return a 404


  Scenario: clearing a particular a request set
    Given getting 'leaving' with request body:
    """
    See you later
    """
    When I clear 'greeting' requests from the MockServer
    Then 'See you later' should have been tracked for 'leaving'