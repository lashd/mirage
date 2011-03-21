Feature: If you want to see the content of a particular response without triggering then it can be peeked instead.
  To do this, the responses unique id is required to identify it


  Scenario: Peeking a text based response
    Given I hit 'http://localhost:7001/mirage/set/greeting' with parameters:
      | response | Hello |

    When I hit 'http://localhost:7001/mirage/peek/1'
    Then 'Hello' should be returned


  Scenario: Peeking a file based response
    Given I hit 'http://localhost:7001/mirage/set/download' with parameters:
      | file | features/resources/test.zip |
    When I hit 'http://localhost:7001/mirage/peek/1'
    Then the response should be a file the same as 'features/resources/test.zip'


  Scenario: Peeking a response that does not exist
    When I hit 'http://localhost:7001/mirage/peek/1'
    Then a 404 should be returned


