@command_line
Feature: Interacting with Mirage is done via HTTP using a REST style URLs and therefor you can interact with it in any language
  that has a HTTP client. If however you are using Ruby you can use the Mirage Client that comes in the Mirage distribution.

  By default the client is configured to connect to an instance of the Mirage server on localhost:7001 which the default port that Mirage starts on.

  Background:
    Given the following gems are required to run the Mirage client test code:
    """
    require 'rubygems'
    require 'rspec'
    require 'mirage'
    """


  Scenario: connecting to mirage running on a different url
    Given I run 'mirage start -p 9001'
    Then I run
    """
      Mirage::Client.new("http://localhost:9001/mirage").running?.should == true
    """


  Scenario: checking if mirage is running
    Then I run
    """
      Mirage::Client.new.running?.should == false
    """
    Given Mirage is running
    Then I run
    """
      Mirage::Client.new.running?.should == true
    """