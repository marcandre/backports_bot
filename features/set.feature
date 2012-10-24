Feature: Set File Tags
  In order to keep track of my files
  As a user
  I want to be able to set new tags on files
  
  Scenario: Set tags on an already tagged file
    Given the example configuration
    When I set the tag "test2" for "mmd_crazy_tags.mmd"
    Then the output should match /New tags for .*mmd_crazy_tags.mmd: asdf, sdfg, dfgh, fghj, qwer, test2/
  
  Scenario: Set tags on an untagged file
    Given the example configuration
    When I set the tag "test" for "mmd_no_tags.mmd"
    Then the output should match /New tags for .*mmd_no_tags.mmd: test/
