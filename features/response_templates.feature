Feature: Parts of a response can be substitued for values found in the request body or query string.
  This allows dynamic content to be sent back to a client.

  To do this, substitution patterns are put in to the response. When the response is triggered, the patterns are used to search the request body
  and then the query string for matches. Patterns can be either the name of a parameter found in the query string, or a regular expression with a single
  matching group which is what is put in to the response.


  Scenario: A response template populated from matches found in the request body using a regex
    Given I hit 'http://localhost:7001/mirage/set/greeting' with parameters:
      | response | Hello ${<firstname>(.*?)</firstname>} ${<surname>(.*?)</surname>}, how are you? |

    When I hit 'http://localhost:7001/mirage/get/greeting' with request body:
    """
    <grettingRequest>
      <firstname>Leon</firstname>
      <surname>Davis</surname>
    </greetingRequest>
    """
    Then 'Hello Leon Davis, how are you?' should be returned


  Scenario: A response template populated from match found in the query string using a request parameter name
    Given I hit 'http://localhost:7001/mirage/set/greeting' with parameters:
      | response | Hello ${name}, how are you? |

    When I hit 'http://localhost:7001/mirage/get/greeting' with parameters:
      | name | Leon |
    Then 'Hello Leon, how are you?' should be returned


  Scenario: Response template populated from match found in the query string using a regex
    Given I hit 'http://localhost:7001/mirage/set/greeting' with parameters:
      | response | Hello ${name=([L\|l]eon)}, how are you? |

    When I hit 'http://localhost:7001/mirage/get/greeting' with parameters:
      | parameter | value |
      | name      | Leon  |
    Then 'Hello Leon, how are you?' should be returned


  Scenario: No match is found in either the request body or query string
    Given I hit 'http://localhost:7001/mirage/set/greeting' with parameters:
      | response | Hello ${<name>(.*?)</name>}, how are you? |

    When  I hit 'http://localhost:7001/mirage/get/greeting'
    Then 'Hello ${<name>(.*?)</name>}, how are you?' should be returned
