# -*- encoding : utf-8 -*-
require 'tmpdir'

class File
  def self.tmpnam(ext = '')
    if ext != ''
      if ext[0] != '.'
        ext = ".#{ext}"
      end
    end
    
    pid = Process.pid
    time = Time.now
    sec = time.to_i
    usec = time.usec
    
    counter = 0
    path = File.join(Dir.tmpdir, "#{pid}_#{sec}_#{usec}_#{rand(1000)}#{ext}")
    
    # This is a corner case that should effectively never be possible, so
    # don't try to cover it.
    #:nocov:
    while File.exist? path
      sec = Time.now.to_i
      usec = Time.now.usec
      path = File.join(Dir.tmpdir, "#{pid}_#{sec}_#{usec}_#{rand(1000)}#{ext}")
      
      counter += 1
      raise 'ERROR: Cannot get unique temporary name' if counter >= 100
    end
    #:nocov:
    
    path
  end
end
