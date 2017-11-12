Feature: Deleting tracked requests
  Tracked request data can be deleted

  Background: The MockServer has already got a response for greeting and leaving on it.
    Given the following template template:
    """
      {
         "response":{
            "body":"Hello"
         }
      }
    """
    And 'response.body' is base64 encoded
    And the template is sent using PUT to '/templates/greeting'

    Given the following template template:
    """
      {
         "response":{
            "body":"Goodbye"
         }
      }
    """
    And 'response.body' is base64 encoded
    And the template is sent using PUT to '/templates/leaving'


    And GET is sent to '/responses/greeting'
    And GET is sent to '/responses/leaving'

    
  Scenario: Deleting all requests
    And DELETE is sent to '/requests'

    When GET is sent to '/requests/1'
    Then the following json should be returned:
    """
      []
    """
    When GET is sent to '/requests/2'
    Then the following json should be returned:
    """
      []
    """



  Scenario: Deleting a stored request for a particular response
    And DELETE is sent to '/requests/1'

    When GET is sent to '/requests/1'
    Then the following json should be returned:
    """
      []
    """
    When GET is sent to '/requests/2'
    Then there should be '1' request tracked

