Feature: Output from Mirage is stored in mirage.log.
  This file is located at the root from which mirage is started.

  Scenario: response is set.
    Given I send PUT to 'http://localhost:7001/mirage/templates/greeting' with body 'Hello'
    Then mirage.log should contain '/mirage/templates/greeting'