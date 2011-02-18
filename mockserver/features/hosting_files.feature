Feature: Instead of hosting a text based response on the mockserver, you can set a file to be returned.

  Scenario: File a default response
    Given a file ''
    And it is put as the response for 'thing'
    When I hit