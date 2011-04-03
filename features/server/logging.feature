Feature: Output from Mirage is stored in mirage.log.
  This file is located at the root from which mirage is started.

  Scenario: response is set.
    Given I post to 'http://localhost:7001/mirage/set/greeting' with parameters:
      | response | Hello |
    Then mirage.log should contain '/mirage/set/greeting?response=Hello'