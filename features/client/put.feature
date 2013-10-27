Feature: Adding Templates

  The Mirage client provides methods for setting Templates.

  The client will escape all data for you so your free to just get on with using Mirage :)

  Body, Header, and Parameter requirements can be specified as either a String or Regexp

  Background:
    Given the following gems are required to run the Mirage client test code:
    """
    require 'rubygems'
    require 'rspec/expectations'
    require 'mirage/client'
    """


  Scenario: Setting a Template on Mirage
    Given I run
    """
    Mirage::Client.new.put('greeting','hello')
    """
    When GET is sent to '/responses/greeting'
    Then 'hello' should be returned

  Scenario: Setting the required HTTP method
    Given I run
    """
    Mirage::Client.new.put('greeting', 'Hello Leon') do
      http_method 'POST'
    end
    """
    When GET is sent to '/responses/greeting'
    Then a 404 should be returned
    When POST is sent to '/responses/greeting'
    Then 'Hello Leon' should be returned


  Scenario: Setting a requirement on body content
    Given I run
    """
    Mirage::Client.new.put('greeting', 'Hello Leon') do
      http_method 'POST'
      required_body_content << /leon/
    end
    """
    When POST is sent to '/responses/greeting'
    Then a 404 should be returned
    When I send POST to '/responses/greeting' with request entity
    """
     <greetingRequest>
      <name>leon</name>
     </greetingRequest>
    """
    Then 'Hello Leon' should be returned

  Scenario: Setting a requirement on requests parameters
    Given I run
    """
    Mirage::Client.new.put('greeting', 'Hello Leon') do
      http_method 'POST'
      required_parameters[:name] = /leon/
    end
    """
    When POST is sent to '/responses/greeting'
    Then a 404 should be returned
    When I send POST to '/responses/greeting' with parameters:
      | name | leon |

    Then 'Hello Leon' should be returned

  Scenario: setting a response as default
    Given I run
    """
    Mirage.start.clear

    Mirage::Client.new.put('greeting', 'default greeting') do
      default true
    end
    """
    When GET is sent to '/responses/greeting/for/joel'
    Then 'default greeting' should be returned


  Scenario: Setting the content type
    Given I run
    """
    Mirage::Client.new.put('greeting', '<xml></xml>') do
      content_type 'text/xml'
    end
    """
    When GET is sent to '/responses/greeting'
    And the response 'content-type' should be 'text/xml'


  Scenario: Setting the HTTP status code
    Given I run
    """
    Mirage::Client.new.put('greeting', 'hello'){status 203}
    """
    When GET is sent to '/responses/greeting'
    Then a 203 should be returned


  Scenario: Setting a delay
    Given I run
    """
    Mirage::Client.new.put('greeting', 'hello'){delay 2}
    """
    When GET is sent to '/responses/greeting'
    Then it should take at least '2' seconds
