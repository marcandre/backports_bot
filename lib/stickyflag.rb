# -*- encoding : utf-8 -*-

require 'rubygems'
require 'thor'
require 'backports'

# Set the superclass before we require anything else
class StickyFlag < Thor; end

require 'stickyflag/version'

require 'stickyflag/patches/tempfile_encoding'
require 'stickyflag/patches/tmpnam.rb'

require 'stickyflag/tags/source_code'
require 'stickyflag/tags/c'
require 'stickyflag/tags/mmd'
require 'stickyflag/tags/pdf'
require 'stickyflag/tags/png'
require 'stickyflag/tags/tex'

require 'stickyflag/configuration'
require 'stickyflag/paths'
require 'stickyflag/external_cmds'
require 'stickyflag/database'
require 'stickyflag/tag_factory'

class StickyFlag
  include Thor::Actions
  class_option :color, :required => false, :default => true,
    :desc => 'if true, print our status messages in color', :type => :boolean
  class_option :force, :requires => false, :default => false, :aliases => '-f',
    :desc => 'do not print diagnostic messages for missing files or empty tags on multiple-file operations'
  class_option :quiet, :required => false, :default => false, :aliases => '-q',
    :desc => 'if true, print only essential output to the console (skip empty tags, diagnostics)'

  include Paths
  include Configuration
  include ExternalCmds
  include TagFactory
  include Database

  def initialize(*args)
    super
    
    if options.color?
      self.shell = Thor::Shell::Color.new
    end
    
    load_config!
    find_external_cmds
    load_database
  end

  desc 'config', "display and set configuration parameters"
  long_desc <<-LONGDESC
    `stickyflag config` allows you to set persistent configuration parameters
    for StickyFlag.
    
    With only --key <key> specified, display the current value for the given key.
    
    With --key <key> <value>, set the value for the key.
    
    With the --list option, list all available configuration parameters and 
    their current values.
  LONGDESC
  method_option :key, :aliases => '-k', :required => false,
    :desc => 'the configuration key to set', :type => :string
  method_option :list, :aliases => '-l', :default => false, :required => false,
    :desc => 'list all available configuration options', :type => :boolean
  method_option :reset, :default => false, :required => false,
    :desc => 'reset *all* configuration settings to defaults', :type => :boolean
  def config(value = nil)
    if options.reset?
      reset_config!
      return
    end
    
    if options.list? || (options[:key].nil? && value.nil?)
      dump_config
      return
    end
    
    if options[:key].nil?
      raise Thor::Error.new("ERROR: Cannot set a value without a key specified")
    end
    
    if value.nil?
      value = get_config options[:key]
      say "#{options[:key]}: '#{value}'"
      return
    end
    
    set_config options[:key], value
    say "'#{options[:key]}' set to '#{value}'" unless options.quiet?
    
    save_config!
  end
  
  desc 'get [FILES]', "print the tags set for a set of files"
  long_desc <<-LONGDESC
    `stickyflag get` lets you look at the tags that have been applied to
    a file or set of files.
  LONGDESC
  def get(*files)
    if files.empty?
      raise Thor::Error.new("stickyflag get requires at least 1 argument: \"stickyflag get [FILES]\"")
    end
    
    files.each do |file_name|
      unless File.exist? file_name
        say_status :error, "File #{file_name} does not exist", :red unless options.force? || options.quiet?
        next
      end
      
      tags = get_tags_for file_name
      if tags.empty?
        say "#{file_name}: no tags" unless options.force? || options.quiet?
        next
      else
        say "#{file_name}: #{tags.join(', ')}"
        next
      end
    end
  end
  
  
  desc 'set [FILE] [TAG]', "set a tag for a file"
  long_desc <<-LONGDESC
    `stickyflag set` lets you add one particular tag to the tags present in a
    given file.  Specify the file you want to modify, and the tag you want to
    add.
  LONGDESC
  def set(file_name, tag)
    check_tag tag
    
    unless File.exist? file_name
      say_status :error, "File #{file_name} does not exist", :red unless options.quiet?
      return
    end
    
    set_tag_for file_name, tag
    
    tags = get_tags_for file_name
    say_status :success, "New tags for #{file_name}: #{tags.join(', ')}", :green unless options.quiet?
  end
  
  
  desc 'unset [FILE] [TAG]', "remove a tag from a file"
  long_desc <<-LONGDESC
    `stickyflag unset` lets you delete one tag from the tags present in a file.
    Specify the file you want to modify, and the tag you want to remove.  This
    action will fail if the tag is not set in the requested file.
  LONGDESC
  def unset(file_name, tag)
    check_tag tag
    
    unless File.exist? file_name
      say_status :error, "File #{file_name} does not exist", :red unless options.quiet?
      return
    end
    
    unset_tag_for file_name, tag
    
    # Unsetting a tag might leave us with no tags at all, which makes this more
    # complicated than the #set behavior
    unless options.quiet?
      tags = get_tags_for file_name
      if tags.empty?
        say_status :success, "New tags for #{file_name}: no tags", :green
      else
        say_status :success, "New tags for #{file_name}: #{tags.join(', ')}", :green
      end
    end
  end
  
  
  desc 'clear [FILES]', "remove all tags from a set of files"
  long_desc <<-LONGDESC
    `stickyflag clear` removes all tags that have been applied to the given 
    list of files.
  LONGDESC
  def clear(*files)
    if files.empty?
      raise Thor::Error.new("stickyflag clear requires at least 1 argument: \"stickyflag clear [FILES]\"")
    end
    
    files.each do |file_name|
      unless File.exist? file_name
        say_status :error, "File #{file_name} does not exist", :red unless options.force? || options.quiet?
        return
      end
      
      clear_tags_for file_name
      say_status :success, "Tags cleared for #{file_name}", :green unless options.quiet?
    end
  end
  
  desc 'update', "update the tag database from the files on disk"
  long_desc <<-LONGDESC
    `stickyflag update` will read all files under the current directory (or
    using the `root` configuration key) and refresh the database based on their
    contents.
  LONGDESC
  def update
    root = get_config(:root).strip
    root = '.' if root.empty? || root.nil?
    
    update_database_from_files root
  end
  
  desc 'tags', "show the list of currently used tags"
  long_desc <<-LONGDESC
    `stickyflag tags` shows the list of currently used tags as present in the
    database.  Note that this may be out of date with respect to the contents
    of the disk, and can be refreshed using `stickyflag update`.
  LONGDESC
  def tags
    say "Tags currently in use:" unless options.quiet?
    padding = ''
    padding = '   ' unless options.quiet?
    
    tag_list.each do |t|
      say "#{padding}#{t}"
    end
  end
  
  desc 'find [TAG] [...]', "show all files that are tagged with the given tags"
  long_desc <<-LONGDESC
    `stickyflag find` locates all files that have a given tag or set of tags.
    If multiple tags are provided, returned files must have all those tags.
  LONGDESC
  def find(*tags)
    if tags.empty?
      raise Thor::Error.new("stickyflag find requires at least 1 argument: \"stickyflag find [TAG] [...]\"")
    end
    tags.each { |t| check_tag t }
    
    files_for_tags(tags).each do |file|
      say file
    end
  end
  
  private
  
  def check_tag(tag)
    if tag.include? ','
      raise Thor::Error.new("ERROR: Tag names cannot include a comma.")
    end
    if tag.empty?
      raise Thor::Error.new("ERROR: Cannot set an empty tag.")
    end
  end
end
