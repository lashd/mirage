Feature: The mockserver can be configured to return a default response every time the relavent end point is hit.

  Scenario: A response without any selection criteria
    Given I hit 'http://localhost:7001/mirage/set/greeting' with parameters:
      | response | Hello, how are you? |

    When getting 'greeting'
    Then 'Hello, how are you?' should be returned


  Scenario: A response hosted on a complex endpoint
    Given I hit 'http://localhost:7001/mirage/set/say/hello/to/me' with parameters:
      | response | Hello to me |

    When getting 'say/hello/to/me'
    Then 'Hello to me' should be returned


  Scenario: A response is not supplied
    Given an attempt is made to set 'greeting' without a response
    Then a 500 should be returned


  Scenario: Response does not exist
    When getting 'response_that_does_not_exist'
    Then a 404 should be returned


