Feature: Having set up the Mirage with a number of defaults, your tests may continue to change its state.
  Clearing and resetting all of your responses, potentially hundreds of times, can be time expensive.

  Mirage provides the ability to save its current state and to revert back to that state.

  Background: The MockServer has been setup with some default responses
    Given the following template template:
    """
      {
         "response":{
            "body":"The default greeting"
         }
      }
    """
    And 'response.body' is base64 encoded
    And the template is sent using PUT to 'http://localhost:7001/mirage/templates/greeting'

    
  Scenario: Saving Mirage and reverting it
    Given PUT is sent to 'http://localhost:7001/mirage/backup'
    And the following template template:
    """
      {
         "response":{
            "body":"Changed"
         }
      }
    """
    And 'response.body' is base64 encoded
    And the template is sent using PUT to 'http://localhost:7001/mirage/templates/greeting'
    
    When PUT is sent to 'http://localhost:7001/mirage'
    And GET is sent to 'http://localhost:7001/mirage/responses/greeting'

    Then 'The default greeting' should be returned