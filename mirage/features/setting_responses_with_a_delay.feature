Feature: It is possible to make the the MockServer introduce a delay before responding to a client. This lets you simulate real world
  conditions and make your application wait before receiving a response.

Scenario: Response with a delay
  Given the response for 'an_appology' with a delay of '4' is:
    """
    Sorry it took me so long!
    """
  When getting 'an_appology'
  Then it should take at least '4' seconds
