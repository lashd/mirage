Feature: After a response has been served from the MockServer, the content of the request triggered it can be retrieved which
  is useful for testing that the correct information was sent to the endpint that the MockServer is stubbing,

  On setting a response on the MockServer a unique id is returned which can be used to look up the last request made to
  get that response. If the the response is reset then the same id is returned in order to make it easier to keep track of.

  Responses hosted on the same endpoint but with a pattern are considered unique and so get their own ID.

  If there is content in the request body because something like a web service is called the request body content is returned.
  If there is nothing in the request body then the query string is returned.

  Scenario: The MockServer returns a response
    Given I hit 'http://localhost:7001/mirage/set/greeting' with parameters:
      | response | Hello |

    When I hit 'http://localhost:7001/mirage/get/greeting' with request body:
    """
    Hello MockServer
    """
    And I hit 'http://localhost:7001/mirage/query/1'
    Then 'Hello MockServer' should be returned

    When I hit 'http://localhost:7001/mirage/get/greeting' with parameters:
      | surname   | Davis |
      | firstname | Leon  |
    And I hit 'http://localhost:7001/mirage/query/1'
    Then 'surname=Davis&firstname=Leon' should be returned


  Scenario: The MockServer has not responsed
    Given I hit 'http://localhost:7001/mirage/set/greeting' with parameters:
      | response | Hello |

    When I hit 'http://localhost:7001/mirage/query/1'
    Then a 404 should be returned


  Scenario: A response is peeked at
    Given I hit 'http://localhost:7001/mirage/set/greeting' with parameters:
      | response | Hello |

    When I hit 'http://localhost:7001/mirage/get/greeting' with request body:
    """
    Hello MockServer
    """
    And I hit 'http://localhost:7001/mirage/peek/1'

    And I hit 'http://localhost:7001/mirage/query/1'
    Then 'Hello MockServer' should be returned


  Scenario: The same endpoint is set more than once
    Given I hit 'http://localhost:7001/mirage/set/greeting' with parameters:
      | response | Hello |

    Then '1' should be returned
    Given I hit 'http://localhost:7001/mirage/set/greeting' with parameters:
      | response | Hi |

    Then '1' should be returned


  Scenario: A default response and one for the same endpoint with but with a pattern is added to the MockServer
    When I hit 'http://localhost:7001/mirage/set/greeting' with parameters:
      | response | Hello who ever you are |
    Then '1' should be returned

    When I hit 'http://localhost:7001/mirage/set/greeting' with parameters:
      | response | Hello Leon |
      | pattern  | Leon       |
    Then '2' should be returned

    When I hit 'http://localhost:7001/mirage/get/greeting' with request body:
    """
    My name is Joel
    """
    And I hit 'http://localhost:7001/mirage/get/greeting' with request body:
    """
    My name is Leon
    """
    And I hit 'http://localhost:7001/mirage/query/1'
    Then 'My name is Joel' should be returned
    And I hit 'http://localhost:7001/mirage/query/2'
    Then 'My name is Leon' should be returned


