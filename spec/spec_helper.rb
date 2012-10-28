# -*- encoding : utf-8 -*-
$KCODE = 'U' if RUBY_VERSION < "1.9.0"
ENV['RSPEC_TESTING'] = 'true'

require 'rubygems'
require 'bundler/setup'
require 'simplecov' unless ENV["CI"] == 'true'

require 'backports'
require 'rspec/autorun'
require 'stickyflag'

Dir['./spec/support/**/*.rb'].map { |f| require f }

RSpec.configure do |c|
  c.before(:each) do    
    # Don't write anything to the console
    Thor::Shell::Basic.any_instance.stub(:say) { }
    Thor::Shell::Basic.any_instance.stub(:say_status) { }    
  end
end

