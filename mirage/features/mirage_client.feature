Feature: Interacting with Mirage is done via HTTP using a REST style URLs and therefor you can interact with it in any language
  that has a HTTP client. If however you are using Ruby you can use the Mirage Client that comes in the Mirage distribution.

  By default the client is configured to connect to an instance of the Mirage server on localhost:7001 which the default port that Mirage starts on.

  Scenario: Connecting with the default settings.


  Scenario: Setting
    Given the file 'mirage_client.rb' contains:
    """
    require 'mirage'
    Mirage::Client.new.set('greeting',:response => 'hello')
    """
    When running 'ruby mirage_client.rb'
    And getting 'greeting'
    Then 'hello' should be returned

  Scenario: Getting

  Scenario: Checking

  Scenario: Peeking

  Scenario: Setting defaults

  Scenario: Clearing