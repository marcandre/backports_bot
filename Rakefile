require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

require 'cucumber'
require 'cucumber/rake/task'
Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = 'features --quiet'
end


task :default do
  Rake::Task[:spec].execute
  if RUBY_PLATFORM != 'java'
    Rake::Task[:features].execute
  end
end
