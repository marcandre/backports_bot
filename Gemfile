source :rubygems

gem 'thor'

gem 'backports'
if RbConfig::CONFIG['target_os'] =~ /linux/i
  gem 'xdg'
end

gem 'sqlite3'

gem 'chunky_png'
platforms :ruby do
  # This reimplements much of the core of chunky_png in C, for more
  # speed, but isn't required (e.g., on JRuby)
  gem 'oily_png', :require => false
end

group :test do
  gem 'rspec'
  gem 'cucumber'
  gem 'aruba'
end

group :development do
  gem 'simplecov', :require => false
  gem 'magic_encoding'
end
