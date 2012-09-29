require 'fileutils'
require 'pathname'

def example_path(example)
  Pathname.new(File.expand_path(File.join(File.dirname(__FILE__), 'examples', example)))
end

def copy_example(example)
  path = example_path(example)
  return unless path.file?
  
  temp_path = Pathname.new(File.expand_path(File.join(File.dirname(__FILE__), "temp-#{Random.rand(1000)}-#{example}")))
  counter = 0
  while temp_path.exist?
    temp_path = Pathname.new(File.expand_path(File.join(File.dirname(__FILE__), "temp-#{Random.rand(1000)}-#{example}")))
    counter += 1
    
    raise "Cannot create temporary file" if counter >= 100
  end
  
  FileUtils.cp(path, temp_path)
  temp_path
end
