Feature: Parts of a response can be substitued for values found in the request body or query string


  Scenario: Response template populated from match found in the request body using a regex
    Given I hit 'http://localhost:7001/mirage/set/greeting' with parameters:
      | response | Hello ${<name>(.*?)</name>}, how are you? |

    When I hit 'http://localhost:7001/mirage/get/greeting' with request body:
    """
    <grettingRequest>
      <name>Leon</name>
    </greetingRequest>
    """
    Then 'Hello Leon, how are you?' should be returned


  Scenario: Response template populated from match found in the query string using a request parameter name
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
