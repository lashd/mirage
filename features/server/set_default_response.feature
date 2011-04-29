Feature: Mirage can respond with a 'default' response when a when the response requested at a sub url is not found.
  I.e.
  if a response is held for 'level1' and request comes in for 'level1/level2' the response for 'level1'
  can be returned if nothing is held for 'level1/level2'

  If a request is made and there is more than one response that could be appropriate then the closet is chosen.

  E.g.
  responses exist for: 'level1' and 'level1/level2'. If a response for 'level1/level2/level3 is made, then the response for
  'level1/level2' will be returned as it is the most specific match out of the two.

  Root responses can cause unexpected behaviour and so in order to qualify as a default reponse a client must knowingly mark it as one.

  Scenario: A default response is returned
    Given I send PUT to 'http://localhost:7001/mirage/responses/level0/level1' with request entity
    """
    { "response" : "another level" }
    """
    Given I send PUT to 'http://localhost:7001/mirage/responses/level1' with request entity
    """
    { "response" : "level 1", "default" : "true" }
    """
    When I send GET to 'http://localhost:7001/mirage/responses/level1/level2.replay'
    Then 'level 1' should be returned


  Scenario: More than one potential default response exists
    Given I send PUT to 'http://localhost:7001/mirage/responses/level1' with request entity
    """
    { "response" : "level 1", "default" : "true" }
    """
    And I send PUT to 'http://localhost:7001/mirage/responses/level1/level2' with request entity
    """
    { "response" : "level 2", "default" : "true" }
    """
    And I send PUT to 'http://localhost:7001/mirage/responses/level1/level2/level3' with request entity
    """
    { "response" : "level 3"}
    """
    And I send PUT to 'http://localhost:7001/mirage/responses/level1/level2/level3/level4' with request entity
    """
    { "response" : "level 4", "pattern" : "a pattern that wont be matched" }
    """
    And I send PUT to 'http://localhost:7001/mirage/responses/leve11/level2/level3/level4/level5' with request entity
    """
    { "response" : "level 5", "default" : "true" }
    """

    When I send GET to 'http://localhost:7001/mirage/responses/level1/level2/level3/level4.replay'
    Then 'level 2' should be returned


  Scenario: There isnt a default response
    Given I send PUT to 'http://localhost:7001/mirage/responses/level1' with request entity
    """
    { "response" : "level 1" }
    """
    When I send GET to 'http://localhost:7001/mirage/responses/level1/level2.replay'
    Then a 404 should be returned