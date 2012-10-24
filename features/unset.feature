Feature: Unset File Tags
  In order to be able to change my mind
  As a user
  I want to be able to unset or remove tags from files
  
  Scenario: Unset tags from a file with multiple tags
    Given the example configuration
    When I unset the tag "asdf" for "mmd_crazy_tags.mmd"
    Then the output should match /New tags for .*mmd_crazy_tags.mmd: sdfg, dfgh, fghj, qwer/
  
  Scenario: Unset tags from a file with one tag
    Given the example configuration
    When I unset the tag "test" for "mmd_with_tag.mmd"
    Then the output should match /New tags for .*mmd_with_tag.mmd: no tags/
