source :rubygems

gem 'thor'

gem 'backports'
if RbConfig::CONFIG['target_os'] =~ /linux/i
  gem 'xdg'
end

gem 'sqlite3'

gem 'chunky_png'
gem 'oily_png'

group :test do
  gem 'rspec'
  gem 'cucumber'
  gem 'aruba'
end

group :development do
  gem 'simplecov', :require => false
  gem 'magic_encoding'
end
