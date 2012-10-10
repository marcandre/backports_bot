require 'tempfile'

class Tempfile
  def self.new_with_encoding(params)
    if RUBY_VERSION >= "1.9.0"
      return Tempfile.new(params, Dir.tmpdir, :encoding => "UTF-8")
    else
      return Tempfile.new(params)
    end
  end
end

