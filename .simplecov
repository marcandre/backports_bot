SimpleCov.start do
  coverage_dir '/spec/coverage'
  add_filter '/spec/'

  add_group 'Frontend', 'bin'
  add_group 'Library code', 'lib'
  add_group 'File taggers', 'lib/tags'
  add_group 'Core patches', 'lib/patches'
end
