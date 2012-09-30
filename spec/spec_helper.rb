require 'rubygems'
require 'rspec/autorun'
require 'thor'
require_relative '../lib/tmpnam'
require_relative '../lib/configuration'

Dir['./spec/support/**/*.rb'].map { |f| require f }

RSpec.configure do |c|
  c.before(:each) do
    # Stub out configuration so it doesn't overwrite whatever the user
    # actually has.
    Configuration.stub(:load_config!) { }
    Configuration.stub(:save_config!) { }
    
    # Don't write anything to the console
    Thor::Shell::Basic.any_instance.stub(:say) { }
    Thor::Shell::Basic.any_instance.stub(:say_status) { }
    Thor::Shell::Color.any_instance.stub(:say) { }
    Thor::Shell::Color.any_instance.stub(:say_status) { }
  end
end

