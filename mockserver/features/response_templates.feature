Feature: Parts of a response can be substitued for values found in the request body or query string


  Scenario: Response template populated from match found in the request body
    Given the response for 'greeting'
    """
    Hello ${<name>(.*?)</name>}, how are you?
    """
    When getting 'greeting' with request body:
    """
    <grettingRequest>
      <name>Leon</name>
    </greetingRequest>
    """
    Then the response should be 'Hello Leon, how are you?'


  Scenario: Response template populated from match found in the query string
    Given the response for 'greeting'
    """
    Hello ${name=([L|l]eon)}, how are you?
    """
    When  getting 'greeting' with query string:
      | parameter | value |
      | name      | Leon  |
    Then the response should be 'Hello Leon, how are you?'


  Scenario: No match is found in either the request body or query string
    Given the response for 'greeting'
    """
    Hello ${<name>(.*?)</name>}, how are you?
    """
    When  getting 'greeting'
    Then the response should be 'Hello ${<name>(.*?)</name>}, how are you?'