# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'stickyflag/version'

Gem::Specification.new do |s|
  s.name = 'stickyflag'
  s.version = StickyFlag::VERSION
  s.required_rubygems_version = Gem::Requirement.new('>= 1.3.6')
  
  s.authors = ['Charles H. Pence']
  s.email = ['charles@charlespence.net']
  s.homepage = 'https://github.com/cpence/stickyflag'
  
  s.summary = 'Tag your files, search by tags'
  s.description = "Set tags and search by them in PDF, MMD, PNG, and other file types"
  
  s.add_runtime_dependency 'thor'
  s.add_runtime_dependency 'backports'
  s.add_runtime_dependency 'xdg'
  s.add_runtime_dependency 'nokogiri'
  s.add_runtime_dependency 'chunky_png'
  s.add_runtime_dependency 'sequel'
  
  if RUBY_PLATFORM == 'java'
    s.platform = 'java'
    s.add_runtime_dependency 'jdbc-sqlite3'
  else
    s.add_runtime_dependency 'sqlite3'
    s.add_runtime_dependency 'oily_png'
  end
  
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'cucumber'
  s.add_development_dependency 'aruba'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'magic_encoding'

  s.files = `git ls-files -- bin/* lib/*`.split("\n")
  s.files |= ['Gemfile', 'stickyflag.gemspec', 'Rakefile', 'LICENSE.md', 'README.md', 'TODO.md']
  
  s.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.default_executable = 'bin/stickyflag'

  s.extra_rdoc_files = ['Rakefile', 'LICENSE.md', 'README.md', 'TODO.md']
  s.rdoc_options = ['--charset=UTF-8']
end
