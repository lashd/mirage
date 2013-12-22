Feature: Placing requirements on requests
  If you want Mirage to be choosy when using a Template to generate a response the following can have requirements placed on them when looking for a suitable to Template to generate responses:

  * request parameters
  * body content
  * HTTP Headers
  * HTTP Method

  When specifying requirements on Headers, request parameters or the body of a request either a litteral string
  or a regular expression can be used for matching.

  Background: There is already a default response for 'greeting'
    Given the following template template:
    """
      {
         "request":{
            "parameters":{},
            "http_method":"get",
            "body_content":[]
         },
         "response":{
            "default":false,
            "body":"Hello Stranger",
            "delay":0,
            "content_type":"text/plain",
            "status":200
         }
      }
    """
    And 'response.body' is base64 encoded
    And the template is sent using PUT to '/templates/greeting'

  Scenario: Configuring a template with requirements on HTTP headers
    Given the following template template:
    """
      {
         "request":{
            "parameters":{},
            "http_method":"get",
            "body_content":[]
         },
         "response":{
            "default":false,
            "body":"Hello Stranger",
            "delay":0,
            "content_type":"text/plain",
            "status":200
         }
      }
    """
    And 'response.body' is base64 encoded
    And the template is sent using PUT to '/templates/greeting'


  Scenario: Configuring a template with requirements on request parameters
    Given the following template template:
    """
      {
         "request":{
            "parameters":{
                "firstname" : "%r\{.*e}",
                "surname"   : "Blogs"
            },
            "http_method":"get",
            "body_content":[]
         },
         "response":{
            "default":false,
            "body":"Hello Joe",
            "delay":0,
            "content_type":"text/plain",
            "status":200
         }
      }
    """
    And 'response.body' is base64 encoded
    And the template is sent using PUT to '/templates/greeting'

    When I send GET to '/responses/greeting' with parameters:
    |firstname|Joe  |
    |surname  |Blogs|
    Then 'Hello Joe' should be returned

  Scenario: Configuring a template with requirements on the body
    Given the following template template:
    """
      {
         "request":{
            "parameters":{},
            "http_method":"POST",
            "body_content":["Joe", "%r{B..gs}"]
         },
         "response":{
            "default":false,
            "body":"Hello Joe",
            "delay":0,
            "content_type":"text/plain",
            "status":200
         }
      }
    """
    And 'response.body' is base64 encoded
    And the template is sent using PUT to '/templates/greeting'

    When I send POST to '/responses/greeting' with request entity
    """
    {"username":"Joe Blogs"}
    """
    Then 'Hello Joe' should be returned


    
      