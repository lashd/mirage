Feature: Mirage can also be used to host files.

  Scenario: A file is set as a response with correct header value
    Given the file 'test.xml' contains:
    """
    <profile><name>Leon</name></profile>
    """
    Given I send PUT to 'http://localhost:7001/mirage/templates/some/location/download' with file: scratch/test.xml and headers:
      | X-mirage-file | true                   |

    When I send GET to 'http://localhost:7001/mirage/responses/some/location/download'
    Then the response should be the same as the content of 'scratch/test.xml'
