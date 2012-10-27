# -*- encoding : utf-8 -*-
require 'rspec/expectations'
require 'cucumber/formatter/unicode'
require 'aruba/cucumber'
require_relative '../../spec/support/examples'

Given /a clean configuration/ do
  FileUtils.rm $paths.config_path if File.exist? $paths.config_path
end

Given /the example configuration/ do
  path = example_root
  
  steps %Q{
    Given a clean configuration
    When I run `stickyflag config -k root '#{path}'`
    And I run `stickyflag update`
  }
end

When /I set the configuration key "(.*?)" to "(.*?)"$/ do |key, val|
  steps %Q{
    When I run `stickyflag config -k '#{key}' '#{val}'`
  }
end

When /I get the configuration key "(.*?)"$/ do |key|
  steps %Q{
    When I run `stickyflag config -k '#{key}'`
  }
end
