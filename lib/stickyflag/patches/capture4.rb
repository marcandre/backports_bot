
module Open4
  unless Open4.respond_to? :capture4
    def capture4(*args)
      stdout_str = ''
      stderr_str = ''
      
      status = Open4.popen4(*args) do |p, i, o, e|
        out_reader = Thread.new { o.read }
        err_reader = Thread.new { e.read }
        i.close
        stdout_str = out_reader.value
        stderr_str = err_reader.value

        stdout_str.force_encoding("UTF-8") if RUBY_VERSION >= "1.9.0"
        stderr_str.force_encoding("UTF-8") if RUBY_VERSION >= "1.9.0"
      end
      
      [ stdout_str, stderr_str, status ]
    end
    module_function :capture4
  end
end
