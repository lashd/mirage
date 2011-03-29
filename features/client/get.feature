Feature: the Mirage client provides a method for getting responses
  There is no need to escape any parameters before using the client api as this is done for you.

  Background:
    Given the following gems are required to run the Mirage client test code:
    """
    require 'rubygems'
    require 'rspec'
    require 'mirage'
    """
    And I post to 'http://localhost:7001/mirage/set/greeting' with parameters:
      | response | hello |

  Scenario: getting a response
    Given I run
    """
    Mirage::Client.new.get('greeting').should == 'hello'
    """

  Scenario: getting a response with parameters
    Given I run
    """
    Mirage::Client.new.get('greeting', :firstname => 'leon', :surname => 'davis').should == 'hello'
    """
    And I hit 'http://localhost:7001/mirage/track/1'
    Then 'firstname=leon&surname=davis' should be returned

  Scenario: getting a response with a request body
    Given I run
    """
    Mirage::Client.new.get('greeting','<greetingRequest></greetingRequest>').should == 'hello'
    """
    And I hit 'http://localhost:7001/mirage/track/1'
    Then '<greetingRequest></greetingRequest>' should be returned

  Scenario: getting a response that does not exist
    Given I run
    """
    begin
      Mirage::Client.new.get('response_that_does_not_exits').should == 'hello'
      fail("Error should have been thrown")
    rescue Exception => e
      e.is_a?(Mirage::ResponseNotFound).should == true
    end
    """

