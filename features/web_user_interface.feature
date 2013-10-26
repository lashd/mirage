Feature: Web interface
  Note: This feature is being rewritten but the screens pretty basic so take a look:

  The home page is served from '/' so by default is found at http://localhost:7001/

  Mirage's home page allows you to see what response are currently being hosted.
  From this page you can:
  - See all currently hosted templates
  - Preview at a Templates content
  - View the last request to trigger a particular Template


#  Background: There are already a couple of responses hosted on he Mirage server
#    Given the following template template:
#    """
#      {
#         "response":{
#            "body":"SGVsbG8="
#         },
#         "request":{
#         }
#      }
#    """
#    And the template is sent using PUT to '/templates/greeting'
#
#
#  Scenario: Using the home page to see what response are being hosted
#    Given I goto to the Mirage home page
#    Then I should see 'greeting/*'
#    Then I should see 'leaving'
#
#  Scenario: Using the home page to peek at a response
#    Given I goto ''
#    When  I click 'peek_response_1'
#    Then I should see 'hello'
#
#  Scenario: Using the home page to track if a request has been made
#    Given I send POST to '/responses/greeting' with request entity
#    """
#    Yo!
#    """
#    Given I goto ''
#    When  I click 'track_response_1'
#    Then I should see 'Yo!'