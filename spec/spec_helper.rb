# -*- encoding : utf-8 -*-
$KCODE = 'U' if RUBY_VERSION < "1.9.0"

require 'rubygems'
require 'backports'
require 'rspec/autorun'
require 'thor'
require_relative '../lib/tmpnam'

Dir['./spec/support/**/*.rb'].map { |f| require f }

RSpec.configure do |c|
  c.before(:each) do    
    # Don't write anything to the console
    Thor::Shell::Basic.any_instance.stub(:say) { }
    Thor::Shell::Basic.any_instance.stub(:say_status) { }    
  end
end

