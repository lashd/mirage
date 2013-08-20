Feature: Retrieving
  A Templates body can be previewed


  Scenario: Preview template body
    Given the following template template:
    """
      {
         "response":{
            "body":"SGVsbG8="
         },
         "request":{
         }
      }
    """
    And the template is sent using PUT to '/templates/greeting'
    When GET is sent to '/templates/1/body'
    Then 'Hello' should be returned