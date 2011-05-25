Feature: Its possible introduce a delay before responding to a client with a particular response. This lets you simulate real world
  conditions by making your application wait before receiving a response.

  Scenario: Response with a delay
    Given I send PUT to 'http://localhost:7001/mirage/templates/an_appology' with body 'Sorry' and headers:
    | X-mirage-delay | 4.2 |
    When I send GET to 'http://localhost:7001/mirage/responses/an_appology'
    Then it should take at least '4.2' seconds
