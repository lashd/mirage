Feature: Creating a Template
  Mirage can be configured with Templates. Templates describe the characteristics of responses that should be returned to a client. In addition to this a templates also describe the conditions under which a template may be used to generate a response.

  On setting a template, a unique id is returned. This is a key that can be used to manage the Template.

  Templates can be configured to respond to either, GET, POST, PUT, or DELETE.

  More than one Template can be placed at the same resource address as long as they have different request contraints. In this case they are given different IDs. For example if two templates are configured to respond to request using different HTTP methods then they will not overwrite each other but both be stored.

  Requirements can be specified as required when configuring a Template:
  * request parameters
  * body content - defaults to text/plain
  * HTTP Headers
  * HTTP Method - defaults to HTTP GET

  The following attributes of a response can be configured
  * HTTP status code - defaults to 200
  * Whether this template is to be treated as the default response if a match is not found for a sub URI
  * A delay before the response is returned to the client. This is in seconds and floats are accepted
  * Content-Type

  Things to note:
  ---------------
  The body attribute of the response should be Base64 encoded. This is so that you may specify binary data if that is what you would like to send back to clients.


  Scenario: Setting a Template on Mirage
    Given the following Template JSON:
    """
      {
         "request":{
            "parameters":{},
            "http_method":"get",
            "headers": {},
            "body_content":[]
         },
         "response":{
            "default":false,
            "body":"SGVsbG8=",
            "delay":0,
            "content_type":"text/plain",
            "status":200
         }
      }
    """
    When the template is sent using PUT to '/templates/greeting'
    Then '{"id":1}' should be returned

    When GET is sent to '/responses/greeting'
    Then 'Hello' should be returned
    And a 200 should be returned


  Scenario: Template defaults
    Given the following Template JSON:
    """
    {}
    """
    When the template is sent using PUT to '/templates/greeting'
    Then the template request specification should have the following set:
      | Setting      | Default |
      | parameters   | none    |
      | body content | none    |
      | headers      | none    |
      | HTTP method  | GET     |
    And the template response specification should have the following set:
      | Setting      | Default    |
      | default      | false      |
      | body         | none       |
      | content_type | text/plain |
      | delay        | 0          |
      | status       | 200        |

  Scenario: Making a request that is unmatched
    When GET is sent to '/responses/unmatched'
    Then a 404 should be returned

