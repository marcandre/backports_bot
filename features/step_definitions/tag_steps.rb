require 'rspec/expectations'
require 'cucumber/formatter/unicode'
require 'aruba/cucumber'
require 'backports'
require_relative '../../spec/support/examples'

When /I get the tags for (".*?")$/ do |filename_strings|
  filenames = filename_strings.scan(/"([^"]+?)"/).flatten.map { |f| example_path(f) }  
  steps %Q{
    When I run `stickyflag get #{filenames.join(' ')}`
  }
end

When /I quietly get the tags for (".*?")$/ do |filename_strings|
  filenames = filename_strings.scan(/"([^"]+?)"/).flatten.map { |f| example_path(f) }  
  steps %Q{
    When I run `stickyflag get #{filenames.join(' ')} --quiet`
  }
end
