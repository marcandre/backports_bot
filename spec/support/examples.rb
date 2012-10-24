# -*- encoding : utf-8 -*-
require 'fileutils'
require 'pathname'
require 'tmpdir'

def example_path(example)
  Pathname.new(File.expand_path(File.join(File.dirname(__FILE__), 'examples', example)))
end

def copy_example(example)
  path = example_path(example)
  temp_path = Pathname.new(File.expand_path(File.join(Dir.tmpdir, "temp-#{Random.rand(1000)}-#{example}")))
  
  # If the file doesn't exist, then just return a bad file path
  if path.file?
    counter = 0
    while temp_path.exist?
      temp_path = Pathname.new(File.expand_path(File.join(Dir.tmpdir, "temp-#{Random.rand(1000)}-#{example}")))
      counter += 1
    
      raise "Cannot create temporary file" if counter >= 100
    end
  
    FileUtils.cp(path, temp_path)
  end
  
  temp_path
end
