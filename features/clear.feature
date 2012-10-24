Feature: Clear File Tags
  In order to reset the tags on a file
  As a user with some tagged files
  I want to be able to clear all the file's tags
  
  Scenario: Clear tags from a tagged file
    Given the example configuration
    When I clear the tags for "mmd_crazy_tags.mmd"
    Then the output should match /Tags cleared for .*mmd_crazy_tags\.mmd/
  
  Scenario: Clear tags from an untagged file
    Given the example configuration
    When I clear the tags for "mmd_no_tags.mmd"
    Then the output should match /Tags cleared for .*mmd_no_tags\.mmd/
