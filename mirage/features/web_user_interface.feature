Feature: Mirage's home page allows you to see what response are currently being hosted.
  From this page you can:
  - Peek at a responses content
  - Check the response to see if a request has been made to it

  Background: There are already a couple of responses hosted on he Mirage server
    Given I hit 'http://localhost:7001/mirage/set/greeting' with parameters:
      | response | hello |
    And I hit 'http://localhost:7001/mirage/set/leaving' with parameters:
      | response | goodbye |

  Scenario: Using the home page to see what response are being hosted
    Given I goto 'http://localhost:7001/mirage'
    Then I should see 'greeting'
    Then I should see 'leaving'

  Scenario: Using the home page to peek at a response
    Given I goto 'http://localhost:7001/mirage'
    When  I click 'peek_response_1'
    Then I should see 'hello'

  Scenario: Using the home page to check if a request has been made
    Given I hit 'http://localhost:7001/mirage/get/greeting' with request body:
    """
    Yo!
    """
    Given I goto 'http://localhost:7001/mirage'
    When  I click 'check_response_1'
    Then I should see 'Yo!'

    # TODO - make root responses on web interface