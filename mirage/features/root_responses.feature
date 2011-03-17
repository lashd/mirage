Feature: Mirage can respond with a 'root' response when a when a response requested at a sub url is not found.
  E.g.
  if a response is held for 'greeting' and request comes in for 'greeting/under/a/sub/url' the response for 'greeting'
  can be returned if nothing is held for 'greeting/under/a/sub/url'

  Scenario: a root response is returned
    Given I hit 'http://localhost:7001/mirage/set/greeting' with parameters:
      | response | default greeting |
    When I hit 'http://localhost:7001/mirage/get/greeting/on/a/sub/url'
    Then 'default greeting' should be returned