Feature: the client can be used for setting responses on Mirage.
  Responses and parameters are escaped before sending them to the Mirage server.

  Background:
    Given the following code snippet is included when running code:
    """
    require 'rubygems'
    require 'rspec'
    require 'mirage'
    """

  Scenario: Setting a basic response
    Given run
    """
    Mirage::Client.new.set('greeting',:response => 'hello')
    """
    When getting 'greeting'
    Then 'hello' should be returned

  Scenario: Setting a response with a pattern
    Given run
    """
    Mirage::Client.new.set('greeting', :response => 'Hello Leon', :pattern => '.*?>leon</name>')
    """
    When getting 'greeting'
    Then a 404 should be returned
    When getting 'greeting' with request body:
    """
     <greetingRequest>
      <name>leon</name>
     </greetingRequest>
    """
    Then 'Hello Leon' should be returned

  Scenario: Mirage started with responses in the default location
    Given the file 'defaults/default_greetings.rb' contains:
    """
    Mirage.default do |mirage|
      mirage.set('greeting', :response => 'hello')
      mirage.set('leaving', :response => 'goodbye')
    end
    """
    When run
    """
    Mirage::Client.new.load_defaults
    """
    When getting 'greeting'
    Then 'hello' should be returned
    When getting 'leaving'
    Then 'goodbye' should be returned

  Scenario: Setting a file as a response
    Given run
    """
    Mirage::Client.new.set('download', :file => File.open('features/resources/test.zip'))
    """
    When getting 'download'
    Then the response should be a file the same as 'features/resources/test.zip'