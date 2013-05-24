#TODO - rename responses directory to templates
@command_line
Feature: Preloading templates
  Mirage can be primed with a set of templates.
  By default, Mirage loads any .rb files found in ./responses on startup. Mirage can also be made to load responses from a directory
  of your choosing by using the -d/--defaults option

  Responses can be added to the responses directory and used to prime Mirage after Mirage has been started.

  Priming causes any modifications to Mirage's current state to be lost.


  Scenario: Using the default responses directory
    Given the file 'responses/default_greetings.rb' contains:
    """
    prime do |mirage|
      mirage.templates.put('greeting', 'hello')
    end
    """
    And I run 'mirage start'
    When GET is sent to 'http://localhost:7001/mirage/responses/greeting'
    Then 'hello' should be returned


  Scenario: Using a custom responses directory
    Given Mirage is not running
    And the file '/tmp/responses/default_greetings.rb' contains:
    """
    prime do |mirage|
      mirage.templates.put('greeting', 'hello')
    end
    """
    And I run 'mirage start --defaults /tmp/responses'
    And GET is sent to 'http://localhost:7001/mirage/responses/greeting'
    Then 'hello' should be returned
