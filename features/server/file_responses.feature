Feature: Mirage can also be used to host files.

  Scenario: A file is set as a response
    Given I send PUT to 'http://localhost:7001/mirage/templates/some/location/download' with file: README.md

    When I send GET to 'http://localhost:7001/mirage/responses/some/location/download'
    Then the response should be a file the same as 'README.md'