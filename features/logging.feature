Feature: Output from Mirage is stored in mirage.log.
  This file is located at the root from which mirage is started.

  Scenario: Mirage logs request
    Given GET is sent to 'http://localhost:7001/mirage/templates/greeting'
    Then mirage.log should contain '/mirage/templates/greeting'