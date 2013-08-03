Feature: Checking tracked requests
  After a response has been served from Mirage, the request that triggered it can be retrieved. This is useful
  for testing that the correct information was sent by your application code.

  Use a template's ID to retrieve the last request that was last received.


  Background: A template has already be put on Mirage
    Given the following template template:
    """
      {
         "request" : {
            "http_method" : "post"
         },
         "response":{
            "body":"Hello"
         }
      }
    """
    And 'response.body' is base64 encoded
    And the template is sent using PUT to '/templates/greeting'


  Scenario: Getting request data when the data was in the body.
    Given I send POST to '/responses/greeting' with request entity
    """
    Hello Mirage
    """
    When GET is sent to '/requests/1'
    Then request data should have been retrieved


  Scenario: Getting request data for a template that has not yet served a response.
    Given GET is sent to '/requests/1'
    Then a 404 should be returned

