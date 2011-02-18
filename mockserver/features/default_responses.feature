Feature: The mockserver can be configured to return a default response every time the relavent end point is hit.

  Scenario: A response without any selection criteria
    Given the response for 'greeting'
      """
      Hello, how are you?
      """
    When getting 'greeting'
    Then the response should be 'Hello, how are you?'


