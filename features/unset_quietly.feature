Feature: Silence Extraneous Output on Unset
  In order to use StickyFlag in scripts
  As a power user
  I want to be able to unset tags without any output at all

  Scenario: Unset tags with no output at all
    Given the example configuration
    When I quietly unset the tag "asdf" for "mmd_crazy_tags.mmd"
    Then the output should not contain "mmd_crazy_tags.mmd"
      And the output should not contain "sdfg"
  
  Scenario: Determine quiet unset tag success from return value
    Given the example configuration
    Given PENDING: figure out how to get Thor to do exit codes
    When I quietly unset the tag "asdf" for "mmd_crazy_tags.mmd"
    Then the exit status should be 0
  
  Scenario: Determine quiet unset tag failure from return value
    Given the example configuration
    Given PENDING: figure out how to get Thor to do exit codes
    When I quietly unset the tag "test" for "nonexistent.mmd"
    Then the exit status should not be 0
    