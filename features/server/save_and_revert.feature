Feature: Having set up the Mirage with a number of defaults, your tests may continue to change its state.
  Clearing and resetting all of your responses, potentially hundreds of times, can be time expensive.

  Mirage provides the ability to save of its current state and to revert it back to that state.

  Background: The MockServer has been setup with some default responses
    Given I send PUT to 'http://localhost:7001/mirage/templates/greeting' with body 'The default greeting'

    
  Scenario: Saving Mirage and reverting it
    And I send PUT to 'http://localhost:7001/mirage/backup'
    
    Given I send PUT to 'http://localhost:7001/mirage/templates/leaving' with body 'Goodbye'
    And I send PUT to 'http://localhost:7001/mirage/templates/greeting' with body 'Changed'
    
    And I send PUT to 'http://localhost:7001/mirage'

    When I send GET to 'http://localhost:7001/mirage/responses/leaving'
    Then a 404 should be returned

    When I send GET to 'http://localhost:7001/mirage/responses/greeting'
    Then 'The default greeting' should be returned