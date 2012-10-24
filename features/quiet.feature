Feature: Silence Extraneous Output
  In order to use StickyFlag in scripts
  As a power user
  I want to be able to silence extraneous command output
  
  Scenario: Get tags without worrying about missing tags or files
    When I quietly get the tags for "mmd_crazy_tags.mmd", "mmd_no_tags.mmd", and "nonexistent.mmd"
    Then the output should contain "mmd_crazy_tags.mmd: asdf, sdfg, dfgh, fghj, qwer"
      And the output should not contain "mmd_no_tags.mmd"
      And the output should not contain "nonexistent.mmd"
