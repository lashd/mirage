Feature: Output is store in mirage.log.
  This file is located at which ever path mirage is started from.

  Scenario: response is set.
    Given I post to 'http://localhost:7001/mirage/set/greeting' with parameters:
      | response | Hello |
    Then 'mirage.log' should contain '/mirage/set/greeting?response=Hello'