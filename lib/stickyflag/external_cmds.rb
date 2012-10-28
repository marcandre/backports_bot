# -*- encoding : utf-8 -*-

module StickyFlag
  module ExternalCmds
  
    EXTERNAL_CMDS = {
      'pdftk' => 'read and write PDF tags'
    }
  
    def find_external_cmds
      EXTERNAL_CMDS.each do |cmd, desc|
        path = get_config "#{cmd}_path"
      
        # First, make sure that the listed file actually exists and is executable,
        # so that if it isn't, we'll be able to fix it by checking $PATH down
        # below.
        unless path.nil? || path.empty?
          unless File.executable? path
            say_status :error, "Path set for #{cmd} is invalid", :red unless options.quiet?

            path = ''
            set_config "#{cmd}_path", ''
            set_config "have_#{cmd}", false
          else
            # We do have this, make sure it's set that way
            set_config "have_#{cmd}", true
          end
        end
      
        if path.nil? || path.empty?
          # We don't have a path for this command, see if we can find it
          found = which(cmd)
          if found.nil?
            say_status :warning, "Cannot find #{cmd} in path, will not be able to #{desc}", :yellow unless options.quiet?
            set_config "have_#{cmd}", false
            next
          end
        
          # Okay, found it, set the configuration parameter
          set_config "#{cmd}_path", found
          set_config "have_#{cmd}", true
        end
      end
    
      # Save our results out to the configuration file
      save_config!
    end
  
    private
  
    # Thanks to mislav on Stack Overflow for this
    def which(cmd)
      exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
      ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
        exts.each { |ext|
          exe = "#{path}#{File::SEPARATOR}#{cmd}#{ext}"
          return exe if File.executable? exe
        }
      end
      return nil
    end
    
  end
end
