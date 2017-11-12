Feature: Clearing Templates

  The client can be used to clear responses and tracked request data from Mirage.

  Like when calling Mirage's own interface directly, clearing a template also clears any associated request data

  Background:
    Given the following require statements are needed:
    """
    require 'rubygems'
    require 'mirage/client'
    """

    And a template for 'greeting' has been set with a value of 'Hello'

    And I send GET to '/responses/greeting' with parameters:
      | message | hello there |
    And a template for 'leaving' has been set with a value of 'Goodbye'

    And I send GET to '/responses/greeting' with parameters:
      | message | I'm going |


  Scenario: Clearing a template
    Given I run
    """
    Mirage::Client.new.templates(1).delete
    """
    When GET is sent to '/responses/greeting'
    Then a 404 should be returned
    When GET is sent to '/requests/1'
    Then the following json should be returned:
    """
      []
    """

    When GET is sent to '/responses/leaving'
    Then a 200 should be returned
    When GET is sent to '/requests/2'
    Then a 200 should be returned


  Scenario: Clearing a request
    Given I run
    """
    Mirage::Client.new.requests(1).delete
    """
    When GET is sent to '/requests/1'
    Then the following json should be returned:
    """
      []
    """
    When GET is sent to '/responses/greeting'
    Then a 200 should be returned


  Scenario: Clearing everything
    When I run
    """
    Mirage::Client.new.templates.delete_all
    """
    And GET is sent to '/responses/greeting'
    Then a 404 should be returned

    When GET is sent to '/requests/1'
    Then the following json should be returned:
    """
      []
    """

    And GET is sent to '/responses/leaving'
    Then a 404 should be returned

    When GET is sent to '/requests/2'
    Then the following json should be returned:
    """
      []
    """


  Scenario: Clearing all request data
    When I run
    """
    Mirage::Client.new.requests.delete_all
    """
    When GET is sent to '/requests/1'
    Then the following json should be returned:
    """
      []
    """

    When GET is sent to '/requests/2'
    Then the following json should be returned:
    """
      []
    """