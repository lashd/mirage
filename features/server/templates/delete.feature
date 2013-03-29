Feature: When a template is deleted, any tracked request data is also removed.

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


  Scenario: Deleting all templates
    Given DELETE is sent to 'http://localhost:7001/mirage/templates'
    When GET is sent to 'http://localhost:7001/mirage/responses/greeting'
    Then a 404 should be returned
    When GET is sent to 'http://localhost:7001/mirage/responses/leaving'
    Then a 404 should be returned


  Scenario: Deleting a particular template
    Given DELETE is sent to 'http://localhost:7001/mirage/templates/1'

    When GET is sent to 'http://localhost:7001/mirage/responses/greeting'
    Then a 404 should be returned

    When GET is sent to 'http://localhost:7001/mirage/responses/leaving'
    Then a 200 should be returned

    