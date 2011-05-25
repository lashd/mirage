Feature: If you want to see the content of a particular response without triggering then it can be peeked instead.
  To do this, the responses unique id is required to identify it


  #TODO should return headers as well
  Scenario: Peeking a text based response
    Given I send PUT to 'http://localhost:7001/mirage/templates/greeting' with body 'Hello'
    
    When I send GET to 'http://localhost:7001/mirage/templates/1'
    Then 'Hello' should be returned


    
  Scenario: Peeking a file based response
    Given I send PUT to 'http://localhost:7001/mirage/templates/some/location/download' with file: README.md

    When I send GET to 'http://localhost:7001/mirage/templates/1'
    Then the response should be a file the same as 'README.md'


  Scenario: Peeking a response that does not exist
    When I send GET to 'http://localhost:7001/mirage/templates/1'
    Then a 404 should be returned


