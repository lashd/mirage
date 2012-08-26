@command_line
Feature: Mirage can be primed with a set of responses.
  By default, Mirage loads any rb files found in ./responses on startup. Mirage can also be made to load response for a directory
  of your choosing

  Responses can be added to the responses directory and used to prime Mirage after Mirage has been started.

  Priming mirage causes any modifications to its state to be lost


  Scenario: Mirage is started with the responses to be used for priming located in ./responses
    Given the file 'responses/default_greetings.rb' contains:
    """
    prime do |mirage|
      mirage.put('greeting', 'hello')
      mirage.put('leaving', 'goodbye')
    end
    """
    And I run 'mirage start'
    When I send GET to 'http://localhost:7001/mirage/responses/greeting'
    Then 'hello' should be returned
    When I send GET to 'http://localhost:7001/mirage/responses/leaving'
    Then 'goodbye' should be returned


  Scenario: Mirage is started pointing with a relative path given for the responses directory
    Given the file './custom_responses_location/default_greetings.rb' contains:
    """
    prime do |mirage|
      mirage.put('greeting', 'hello')
    end
    """
    And I run 'mirage start -d ./custom_responses_location'
    When I send GET to 'http://localhost:7001/mirage/responses/greeting'
    Then 'hello' should be returned


  Scenario: Mirage is started pointing with a full path for the responses
    Given Mirage is not running
    And the file '/tmp/responses/default_greetings.rb' contains:
    """
    prime do |mirage|
      mirage.put('greeting', 'hello')
    end
    """
    And I run 'mirage start --defaults /tmp/responses'
    When I send PUT to 'http://localhost:7001/mirage/defaults'
    And I send GET to 'http://localhost:7001/mirage/responses/greeting'
    Then 'hello' should be returned


  Scenario: Priming mirage after its state has been modified
    Given the file 'responses/default_greetings.rb' contains:
    """
    prime do |mirage|
      mirage.put('greeting', 'hello')
    end
    """
    And I run 'mirage start'
    And I send DELETE to 'http://localhost:7001/mirage/templates'
    And I send PUT to 'http://localhost:7001/mirage/templates/a_new_response' with request entity
    """
    new response
    """

    When I send PUT to 'http://localhost:7001/mirage/defaults'
    When I send GET to 'http://localhost:7001/mirage/responses/greeting'
    Then 'hello' should be returned
    When I send GET to 'http://localhost:7001/mirage/responses/a_new_response'
    Then a 404 should be returned

  @command_line
  Scenario: Mirage is started with a bad file
    Given the file 'responses/default_greetings.rb' contains:
    """
    A file with a mistake in it
    """
    When I run 'mirage start'
    Then I should see 'WARN: Unable to load default responses from: responses/default_greetings.rb' on the command line


  Scenario: Mirage is primed with a bad file after it has been started
    Given I run 'mirage start'
    When the file 'responses/default_greetings.rb' contains:
    """
    A file with a mistake in it
    """
    And I send PUT to 'http://localhost:7001/mirage/defaults'
    Then a 500 should be returned