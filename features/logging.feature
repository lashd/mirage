Feature: Output from Mirage is stored in mirage.log.
  This file is located at the root from which mirage is started.

  Scenario: Mirage logs request
    Given GET is sent to '/templates/greeting'
    Then mirage.log should contain '/templates/greeting'