Feature: Mirage can also be used to host files.

  Scenario: A file is set as a response with correct header value
    Given I send PUT to 'http://localhost:7001/mirage/templates/some/location/download' with file: README.md and headers:
      | X-mirage-file | true |

    When I send GET to 'http://localhost:7001/mirage/responses/some/location/download'
    Then the response should be a file the same as 'README.md'


  Scenario: A file is set as a response with incorrect header value
    Given I send PUT to 'http://localhost:7001/mirage/templates/some/location/download' with file: VERSION and headers:
      | X-mirage-file | false |

    When I send GET to 'http://localhost:7001/mirage/responses/some/location/download'
    Then the response should not be a file 
    And '1.3.6' should be returned