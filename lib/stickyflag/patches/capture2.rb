
class IO
  unless IO.respond_to? :capture2
    def self.capture2(*args)
      io = IO.popen(*args)
      pid = io.pid
      stdout_str = io.read

      io.close
      status = $?

      stdout_str.force_encoding("UTF-8") if RUBY_VERSION >= "1.9.0"
              
      [ stdout_str, status ]
    end
  end
end
