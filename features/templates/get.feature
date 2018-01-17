Feature: Retrieving
  Templates can be retrieved by using the ID that was returned when they were created


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
    And the template is sent using PUT to '/templates/greeting'
    When GET is sent to '/templates/1'
    Then the following json should be returned:
    """
      {
         "id": 1,
         "endpoint": "/greeting",
         "requests_url": "http://localhost:7001/requests/1",
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
            "headers":{},
            "body_content":[
            ],
            "http_method":"get"
         }
      }
    """


