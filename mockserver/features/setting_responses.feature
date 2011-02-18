Feature: The mockserver can be configured to return a default response every time the relavent end point is hit.

  Scenario: A response without any selection criteria
    Given the response for 'greeting' is:
    """
    Hello, how are you?
    """
    When getting 'greeting'
    Then 'Hello, how are you?' should be returned

  Scenario: A response is not supplied
    Given an attempt is made to set 'greeting' without a response
    Then a 500 should be returned

    Scenario: Response does not exist
    When getting 'response_that_does_not_exist'
    Then a 404 should be returned


