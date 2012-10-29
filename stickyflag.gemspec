# -*- encoding: utf-8 -*-
require File.expand_path('../lib/stickyflag/version', __FILE__)

Gem::Specification.new do |s|
  s.name = 'stickyflag'
  s.version = StickyFlag::VERSION
  s.date = Date.today.to_s
  s.required_rubygems_version = Gem::Requirement.new('>= 1.3.6')
  
  s.summary = 'Tag your files, search by tags'
  s.description = "Set tags and search by them in PDF, MMD, PNG, and other file types"
  
  s.authors = ['Charles H. Pence']
  s.email = 'charles@charlespence.net'
  s.homepage = 'https://github.com/cpence/stickyflag'
  
  s.add_runtime_dependency 'thor'
  s.add_runtime_dependency 'backports'
  s.add_runtime_dependency 'xdg'
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
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'cucumber'
  s.add_development_dependency 'aruba'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'magic_encoding'

  s.files = `git ls-files`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{|f| File.basename(f)}
  s.default_executable = 'bin/stickyflag'
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")

  s.extra_rdoc_files = ['LICENSE.md', 'README.md', 'Rakefile', 'TODO.md']
  s.rdoc_options = ['--charset=UTF-8']
end
