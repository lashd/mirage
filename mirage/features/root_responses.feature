Feature: Mirage can respond with a 'root' response when a when the response requested at a sub url is not found.
  I.e.
  if a response is held for 'level1' and request comes in for 'level1/level2' the response for 'level1'
  can be returned if nothing is held for 'level1/level2'

  If a request is made and there is more than one response that could be appropriate then the closet is chosen.

  E.g.
  responses exist for: 'level1' and 'level1/level2'. If a response for 'level1/level2/level3 is made, then the response for
  'level1/level2' will be returned as it is the most specific match out of the two.

  Scenario: a root response is returned
    Given I hit 'http://localhost:7001/mirage/set/level1' with parameters:
      | response | level 1 |

    When I hit 'http://localhost:7001/mirage/get/level1/level2'
    Then 'level 1' should be returned


  Scenario: More than one potential root response exists
    Given I hit 'http://localhost:7001/mirage/set/level1' with parameters:
      | response | level 1 |
    Given I hit 'http://localhost:7001/mirage/set/level1/level2' with parameters:
      | response | level 2 |

    When I hit 'http://localhost:7001/mirage/get/level1/level2/level3'
    Then 'level 2' should be returned