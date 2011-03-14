Feature: Having set up the MockServer with a number of defaults, your tests may continue to change the state of the mockserver its own needs.
  Clearing the mockserver and putting back the defaults potentially hundreds of times can be expensive. The MockServer provides the ability to
  take a snapshot of its current state and to roll it back to that state.

  Background: The MockServer has been setup with some default responses
    Given I hit 'http://localhost:7001/mirage/set/greeting' with parameters:
      | response | The default greeting |


  Scenario: Taking a snapshot and rolling it back
    Given  I snapshot the MockServer
    And I hit 'http://localhost:7001/mirage/set/leaving' with parameters:
      | response | Goodye |

    And I hit 'http://localhost:7001/mirage/set/greeting' with parameters:
      | response | Changed |

    And I rollback the MockServer
    When getting 'leaving'
    Then a 404 should be returned
    When getting 'greeting'
    Then 'The default greeting' should be returned