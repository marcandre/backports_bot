Feature: Get File Tags
  In order to know what tags I have set on a file
  As a user with some tagged files
  I want to be able to query the file tags
  
  Scenario: Get tags from a tagged file
    Given the example configuration
    When I get the tags for "mmd_crazy_tags.mmd"
    Then the output should contain "mmd_crazy_tags.mmd: asdf, sdfg, dfgh, fghj, qwer"
  
  Scenario: Get tags from an untagged file
    Given the example configuration
    When I get the tags for "mmd_no_tags.mmd"
    Then the output should contain "mmd_no_tags.mmd: no tags"
