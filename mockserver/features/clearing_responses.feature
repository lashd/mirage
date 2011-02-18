Feature: Once responses are on the MockServer they can be cleared.

  Scenario: Clearing all responses
    Given the response for 'greeting'
    """
    Hello
    """
    And the response for 'leaving'
    """
    Goodbye
    """
    When I clear 'all' responses from the MockServer
    And get 'greeting'
    Then a 404 should be returned
    And get 'leaving'
    Then a 404 should be returned

  Scenario: clearing a particular response set
    Given the response for 'greeting'
    """
    Hello
    """
    And the response for 'leaving'
    """
    Goodbye
    """
    When I clear 'greeting' responses from the MockServer
    And get 'greeting'
    Then a 404 should be returned
    And get 'leaving'
    Then 'Goodbye' should be returned

