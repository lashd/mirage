Feature: Mirage can be configured with endpoints that when request returned defined responses.
  On setting a response, a unique id is retuned. This is a key that can be used to manage the response. E.g. clearing or peek at it.

  Usage:
  ${mirage_url}/set/your/end/point?response=your_response
  ${mirage_url}/set/your/end/point?response=your_response&pattern=pattern


  Scenario: Setting a response without any selection criteria
    Given I hit 'http://localhost:7001/mirage/set/greeting' with parameters:
      | response | Hello, how are you? |

    When I hit 'http://localhost:7001/mirage/get/greeting'
    Then 'Hello, how are you?' should be returned
    And '1' should be returned


  Scenario: A response hosted on a longer url
    Given I hit 'http://localhost:7001/mirage/set/say/hello/to/me' with parameters:
      | response | Hello to me |

    When I hit 'http://localhost:7001/mirage/get/say/hello/to/me'
    Then 'Hello to me' should be returned
    And '1' should be returned


  Scenario: The same endpoint is set more than once
    Given I hit 'http://localhost:7001/mirage/set/greeting' with parameters:
      | response | Hello |
    Then '1' should be returned

    Given I hit 'http://localhost:7001/mirage/set/greeting' with parameters:
      | response | Hi |
    Then '1' should be returned


  Scenario: A response is not supplied
    Given I hit 'http://localhost:7001/mirage/set/greeting'
    Then a 500 should be returned


  Scenario: Getting a response that does not exist
    When I hit 'http://localhost:7001/mirage/get/response_that_does_not_exist'
    Then a 404 should be returned
