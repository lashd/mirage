Feature: It is possible to make the the MockServer introduce a delay before responding to a client. This lets you simulate real world
  conditions and make your application wait before receiving a response.

  Scenario: Response with a delay
    Given I hit 'http://localhost:7001/mirage/set/an_appology' with parameters:
      | response | Sorry it took me so long! |
      | delay    | 4                         |

    When I hit 'http://localhost:7001/mirage/get/an_appology'
    Then it should take at least '4' seconds
