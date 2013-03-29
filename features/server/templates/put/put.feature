Feature: Mirage can be configured with templates that are returned when addressed from ${mirage_url}/responses
  On setting a template, a unique id is returned. This is a key that can be used to manage the template.

  Templates can be configured to respond to either, GET, POST, PUT, or DELETE. If you put more than one template to the same resource address
  but configure them to respond to different HTTP methods, then they are held as seperate resources and are assigned different ids.

  The following can be configured as required in order to invoke a response:
  * request parameters
  * body content - defaults to text/plain
  * HTTP Headers
  * HTTP Method - defaults to HTTP GET

  The following attributes of a response can be configured
  * HTTP status code - defaults to 200
  * Whether this template is to be treated as the default response if a match is not found for a sub URI
  * A delay before the response is returned to the client. This is in seconds, floats are accepted
  * Content-Type

  Request defaults
  |required request parameters | none |
  |required body content       | none |
  |require HTTP headers        | none |
  |required HTTP method        | GET  |

  Response defaults
  | HTTP status code | 200        |
  | treat as default | false      |
  | delay            | 0          |
  | Content-Type     | text/plain |


  Scenario: Setting a template on mirage
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
            "body":"Hello",
            "delay":0,
            "content_type":"text/plain",
            "status":200
         }
      }
    """
    And 'response.body' is base64 encoded
    And the template is sent using PUT to 'http://localhost:7001/mirage/templates/greeting'
    And '{"id":1}' should be returned

    When GET is sent to 'http://localhost:7001/mirage/responses/greeting'
    Then 'Hello' should be returned
    And a 200 should be returned

  Scenario: Making a request that is unmatched
    When GET is sent to 'http://localhost:7001/mirage/responses/unmatched'
    Then a 404 should be returned

