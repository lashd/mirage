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
    And the template is sent using PUT to 'http://localhost:7001/mirage/templates/greeting'

    Given the following template template:
    """
      {
         "response":{
            "body":"Goodbye"
         }
      }
    """
    And 'response.body' is base64 encoded
    And the template is sent using PUT to 'http://localhost:7001/mirage/templates/leaving'


    And GET is sent to 'http://localhost:7001/mirage/responses/greeting'
    And GET is sent to 'http://localhost:7001/mirage/responses/leaving'

    
  Scenario: Deleting all requests
    And DELETE is sent to 'http://localhost:7001/mirage/requests'

    When GET is sent to 'http://localhost:7001/mirage/requests/1'
    Then a 404 should be returned
    When GET is sent to 'http://localhost:7001/mirage/requests/2'
    Then a 404 should be returned



  Scenario: Deleting a stored request for a particular response
    And DELETE is sent to 'http://localhost:7001/mirage/requests/1'

    When GET is sent to 'http://localhost:7001/mirage/requests/1'
    Then a 404 should be returned
    When GET is sent to 'http://localhost:7001/mirage/requests/2'
    Then a 200 should be returned
