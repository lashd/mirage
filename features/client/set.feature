Feature: the Mirage client provides methods for setting responses and loading default responses.
  There is no need to escape any parameters before using the client api as this is done for you.

  Patterns can be either a string or regex object.

  Background:
    Given the following gems are required to run the Mirage client test code:
    """
    require 'rubygems'
    require 'rspec'
    require 'mirage'
    """


  Scenario: Setting a basic response
    Given I run
    """
    Mirage::Client.new.set('greeting','hello')
    """
    When I send GET to 'http://localhost:7001/mirage/responses/greeting'
    Then 'hello' should be returned

  Scenario: Setting the method that a response should be returned on
    Given I run
    """
    Mirage::Client.new.set('greeting', 'Hello Leon', :method => 'POST')
    """
    When I send GET to 'http://localhost:7001/mirage/responses/greeting'
    Then a 404 should be returned
    When I send POST to 'http://localhost:7001/mirage/responses/greeting'
    Then 'Hello Leon' should be returned


  Scenario Outline: Setting a response with a pattern
    Given I run
    """
    Mirage::Client.new.set('greeting', 'Hello Leon', :pattern => <pattern>, :method => 'POST')
    """
    When I send POST to 'http://localhost:7001/mirage/responses/greeting'
    Then a 404 should be returned
    When I send POST to 'http://localhost:7001/mirage/responses/greeting' with request entity
    """
     <greetingRequest>
      <name>leon</name>
     </greetingRequest>
    """
    Then 'Hello Leon' should be returned
  Examples:
    | pattern             |
    | /.*?>leon<\\/name>/ |
    | 'leon'              |


  Scenario: Priming Mirage
    Given Mirage is not running
    And I run 'mirage start'

    When the file 'responses/default_greetings.rb' contains:
    """
    Mirage.prime do |mirage|
      mirage.set('greeting', 'hello')
      mirage.set('leaving', 'goodbye')
    end
    """
    And I run
    """
    Mirage::Client.new.prime
    """
    And I send GET to 'http://localhost:7001/mirage/responses/greeting'
    Then 'hello' should be returned

    When I send GET to 'http://localhost:7001/mirage/responses/leaving'
    Then 'goodbye' should be returned


  Scenario: Priming Mirage when one of the response file has something bad in it
    Given the file 'responses/default_greetings.rb' contains:
    """
    Something bad...
    """
    When I run
    """
    begin
      Mirage::Client.new.prime
      fail("Error should have been thrown")
    rescue Exception => e
      e.is_a?(Mirage::InternalServerException).should == true
    end
    """
#
#
  Scenario: Setting a file as a response
    Given I run
    """
    Mirage::Client.new.set('download', File.open('README.md'))
    """
    When I send GET to 'http://localhost:7001/mirage/responses/download'
    Then the response should be the same as the content of 'README.md'
