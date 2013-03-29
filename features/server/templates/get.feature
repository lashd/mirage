Feature: Templates can be retrieved by using the ID that was returned when they were created


  Scenario: Retrieving a template
    Given the following template template:
    """
      {
         "response":{
            "default":false,
            "body":"Hello",
            "delay":0,
            "content_type":"text/plain",
            "status":200
         },
         "request":{
            "parameters":{

            },
            "body_content":[

            ],
            "http_method":"get"
         }
      }
    """
    And the template is sent using PUT to 'http://localhost:7001/mirage/templates/greeting'
    When GET is sent to 'http://localhost:7001/mirage/templates/1'
    Then the following should be returned:
    """
      {
         "response":{
            "default":false,
            "body":"Hello",
            "delay":0,
            "content_type":"text/plain",
            "status":200
         },
         "request":{
            "parameters":{

            },
            "body_content":[

            ],
            "http_method":"get"
         }
      }
    """


