Feature: Mirage can be configured with endpoints that when request returned defined responses.
  On setting a response, a unique id is retuned. This is a key that can be used to manage the response. E.g. clearing or peek at it.

  Usage:
  ${mirage_url}/set/your/end/point?response=your_response


  Scenario: Setting a response without any selection criteria
    Given I send PUT to 'http://localhost:7001/mirage/greeting' with request entity
    """
    { "response" : "Hello, how are you?" }
    """

    When I send GET to 'http://localhost:7001/mirage/get/greeting'
    Then 'Hello, how are you?' should be returned

  Scenario: A response hosted on a longer url
    Given I send PUT to 'http://localhost:7001/mirage/say/hello/to/me' with request entity
    """
    { "response" : "Hello to me" }
    """
    When I send GET to 'http://localhost:7001/mirage/get/say/hello/to/me'
    Then 'Hello to me' should be returned


  Scenario: The same endpoint is set more than once
    Given I send PUT to 'http://localhost:7001/mirage/greeting' with request entity
    """
    { "response" : "Hello" }
    """
    Then '1' should be returned

    Given I send PUT to 'http://localhost:7001/mirage/greeting' with request entity
    """
    { "response" : "Hi" }
    """
    Then '1' should be returned


  Scenario: A response is not supplied
    Given I send PUT to 'http://localhost:7001/mirage/greeting'
    Then a 500 should be returned


  Scenario: Getting a response that does not exist
    When I send GET to 'http://localhost:7001/mirage/get/response_that_does_not_exist'
    Then a 404 should be returned
