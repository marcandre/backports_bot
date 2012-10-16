# -*- encoding : utf-8 -*-
$KCODE = 'U' if RUBY_VERSION < "1.9.0"

require 'rubygems'
require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
  coverage_dir '/spec/coverage'
end

require 'backports'
require 'rspec/autorun'
require 'thor'
require_relative '../lib/patches/tmpnam'
require_relative '../lib/patches/tempfile_encoding'

Dir['./spec/support/**/*.rb'].map { |f| require f }

RSpec.configure do |c|
  c.before(:each) do    
    # Don't write anything to the console
    Thor::Shell::Basic.any_instance.stub(:say) { }
    Thor::Shell::Basic.any_instance.stub(:say_status) { }    
  end
end

