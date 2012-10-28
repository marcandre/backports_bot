source :rubygems

gem 'thor'
gem 'rake'

gem 'backports'
if RbConfig::CONFIG['target_os'] =~ /linux/i
  gem 'xdg'
end

gem 'rdbi'
gem 'rdbi-driver-sqlite3', :platforms => [ :ruby, :mswin ]
gem 'rdbi-driver-jdbc', :platforms => :jruby, :git => 'git://github.com/cpence/rdbi-driver-jdbc.git'
gem 'jdbc-sqlite3', :platforms => :jruby

gem 'chunky_png'
gem 'oily_png', :platforms => [ :ruby, :mswin ]

group :test do
  gem 'rspec'
  gem 'cucumber'
  gem 'aruba'
end

group :development do
  gem 'simplecov'
  gem 'magic_encoding'
end
