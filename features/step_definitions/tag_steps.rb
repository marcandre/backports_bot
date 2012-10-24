require 'rspec/expectations'
require 'cucumber/formatter/unicode'
require 'aruba/cucumber'
require 'backports'
require_relative '../../spec/support/examples'

When /I get the tags for (".*?")$/ do |filename_strings|
  filenames = filename_strings.scan(/"([^"]+?)"/).flatten.map { |f| "'#{example_path(f).to_s}'" }
  steps %Q{
    When I run `stickyflag get #{filenames.join(' ')}`
  }
end

When /I quietly get the tags for (".*?")$/ do |filename_strings|
  filenames = filename_strings.scan(/"([^"]+?)"/).flatten.map { |f| "'#{example_path(f).to_s}'" }
  steps %Q{
    When I run `stickyflag get #{filenames.join(' ')} --quiet`
  }
end

When /I set the tag "(.*?)" for "(.*?)"$/ do |tag, filename|
  path = copy_example(filename)
  steps %Q{
    When I run `stickyflag set '#{path}' '#{tag}'`
  }
end

When /I quietly set the tag "(.*?)" for "(.*?)"$/ do |tag, filename|
  path = copy_example(filename)
  steps %Q{
    When I run `stickyflag set '#{path}' '#{tag}' --quiet`
  }
end
