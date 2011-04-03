Feature: Mirage can also be used to host files.

  Scenario: A file is set as a response
    Given I hit 'http://localhost:7001/mirage/set/some/location/download' with parameters:
      | response | README.md |

    When I hit 'http://localhost:7001/mirage/get/some/location/download'
    Then the response should be a file the same as 'README.md'