require 'open3'
require 'open4'

module StickyFlag
  def capture3(*args)
    # First, try for Open3.capture3, which is the best solution of all (on
    # Ruby 1.9+).  Note that JRuby's capture3 is broken before version 1.7.1.
    if Open3.respond_to?(:capture3) && (RUBY_PLATFORM != 'java' || JRUBY_VERSION >= '1.7.1')
      return Open3.capture3 *args
    end
    
    # If we are on JRuby, we might have IO.popen4, which does the same thing.
    if IO.respond_to?(:popen4)
      # On JRuby, IO.popen4 will only set $? to a status object if you give it
      # a block (JRUBY-5673).
      stdout_str, stderr_str = [ nil, nil ]
      IO.popen4(*args) do |p, i, o, e|
        i.close
        
        stdout_str = o.read
        stderr_str = e.read
      end
      status = $?

      stdout_str.force_encoding("UTF-8") if RUBY_VERSION >= "1.9.0"
      stderr_str.force_encoding("UTF-8") if RUBY_VERSION >= "1.9.0"
      
      return [ stdout_str, stderr_str, status ]
    end
    
    # If we're not on JRuby, we can use the open4 gem, which will give us both
    # a status and captured stdout and stderr.  
    if RUBY_PLATFORM != 'java'
      pid, stdin, stdout, stderr = Open4.popen4 *args
      stdin.close
      ignored, status = Process.waitpid2 pid
      
      stdout_str = stdout.read
      stderr_str = stderr.read
      
      stdout_str.force_encoding("UTF-8") if RUBY_VERSION >= "1.9.0"
      stderr_str.force_encoding("UTF-8") if RUBY_VERSION >= "1.9.0"
      
      return [ stdout_str, stderr_str, status ]
    end
    
    # Fall back to IO.popen, which won't redirect stderr
    io = IO.popen(args.map {|a| "\"#{a}\""}.join(' '))
    pid = io.pid
    stdout_str = io.read

    io.close
    status = $?

    stdout_str.force_encoding("UTF-8") if RUBY_VERSION >= "1.9.0"
              
    [ stdout_str, '', status ]
  end
  module_function :capture3
end
