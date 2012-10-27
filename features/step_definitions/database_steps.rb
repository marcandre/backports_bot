# -*- encoding : utf-8 -*-
require 'rspec/expectations'
require 'cucumber/formatter/unicode'
require 'aruba/cucumber'

Given /a clean database/ do
  FileUtils.rm $paths.database_path if File.exist? $paths.database_path
end

Given /the example database/ do
  steps %Q{
    Given the example configuration
    When I run `stickyflag update`
  }
end

Given /I update the database in the directory "(.*?)"$/ do |dir|
  steps %Q{
    When I set the configuration key "root" to "#{dir}"
    When I run `stickyflag update`
  }
end

When /I get the list of tags in use/ do
  steps %Q{
    When I run `stickyflag tags`
  }
end

When /I quietly get the list of tags in use/ do
  steps %Q{
    When I run `stickyflag tags --quiet`
  }
end

When /I search for the tag (".*?")$/ do |tag_strings|
  tags = tag_strings.scan(/"([^"]+?)"/).flatten
  steps %Q{
    When I run `stickyflag find #{tags.join(' ')}`
  }
end
