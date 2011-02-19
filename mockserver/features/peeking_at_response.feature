Feature: If you want to see the response that would be when triggered it can be peeked using the unique id of the response

  Scenario: Peeking a response
    Given the response for 'greeting' is:
    """
    Hello
    """
    When peeking at the response for response id '1'
    Then 'Hello' should be returned

  Scenario: Peeking a response that does not exist
    When peeking at the response for response id '1'
    Then a 404 should be returned


