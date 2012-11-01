# -*- encoding : utf-8 -*-
require 'thread'
require 'sequel'

module StickyFlag
  module Database
    def load_database
      @database.disconnect if @database
      
      if RUBY_PLATFORM == 'java'
        @database = Sequel.connect("jdbc:sqlite:#{database_path}")
      else
        @database = Sequel.sqlite(:database => database_path)
      end
      raise Thor::Error.new("ERROR: Could not create database at '#{database_path}'") if @database.nil?
      
      create_tables
      
      # Do not do automatic cleanup from the RSpec test suite; this registers
      # dozens of at_exit hooks and crashes Ruby
      unless ENV['RSPEC_TESTING']
        at_exit { @database.disconnect }
      end
    end
  
    def create_tables
      @database.create_table?(:tag_list) do
        primary_key :id, :type => Bignum
        String :tag_name, :text => true
      end
      @database.create_table?(:file_list) do
        primary_key :id, :type => Bignum
        String :file_name, :text => true
      end
      @database.create_table?(:tagged_files) do
        primary_key :id
        Bignum :file
        Bignum :tag
      end
    end
  
    def drop_tables
      @database.drop_table(:tag_list, :file_list, :tagged_files)
    end
  
    def get_tag_id(tag)
      tag_id = @database[:tag_list].where(:tag_name => tag).get(:id)
      unless tag_id
        tag_id = @database[:tag_list].insert(:tag_name => tag)
      end
      
      tag_id
    end
  
    def get_file_id(file_name)
      file_id = @database[:file_list].where(:file_name => file_name).get(:id)
      unless file_id
        file_id = @database[:file_list].insert(:file_name => file_name)
      end
    
      file_id
    end
  
    def update_database_from_files(directory = '.')
      drop_tables
      create_tables
    
      Dir.glob(File.join(directory, '**', "*{#{available_tagging_extensions.join(',')}}")).each do |file|
        begin
          tags = get_tags_for file
        rescue Thor::Error
          # Just skip this file, then, don't error out entirely
          say_status :warning, "Could not read tags from '#{file}', despite a valid extension", :yellow
          next
        end
        
        # Don't record files in the DB that have no tags
        next if tags.nil? || tags.empty?
      
        file_id = get_file_id file      
        tags.each do |tag|
          tag_id = get_tag_id tag
          @database[:tagged_files].insert(:file => file_id, :tag => tag_id)
        end
      end
    end
  
    def set_database_tag(file_name, tag)
      # Don't put in multiple entries for the same tag
      file_id = get_file_id file_name
      tag_id = get_tag_id tag
      
      return unless @database[:tagged_files].where(:file => file_id).and(:tag => tag_id).empty?
      @database[:tagged_files].insert(:file => file_id, :tag => tag_id)
    end
  
    def unset_database_tag(file_name, tag)
      file_id = get_file_id file_name
      tag_id = get_tag_id tag
      @database[:tagged_files].where(:file => file_id).and(:tag => tag_id).delete
    
      # See if that was the last file with this tag, and delete it if so
      if @database[:tagged_files].where(:tag => tag_id).empty?
        @database[:tag_list].where(:id => tag_id).delete
      end
    end
  
    def clear_database_tags(file_name)
      file_id = get_file_id file_name
      @database[:tagged_files].where(:file => file_id).delete
    
      # That operation might have removed the last instance of a tag, clean up
      # the tag list
      @database[:tag_list].each do |row|
        raise Thor::Error.new("INTERNAL ERROR: Database row error in tag_list") unless row.include? :id
        tag_id = row[:id]
        
        if @database[:tagged_files].where(:tag => tag_id).empty?
          @database[:tag_list].where(:id => tag_id).delete
        end
      end
    end
  
    def files_for_tags(tags)
      # Map tags to tag IDs, but don't add any missing tags
      bad_tag = false
      tag_ids = []
      tags.each do |tag|
        tag_id = @database[:tag_list].where(:tag_name => tag).get(:id)
        unless tag_id
          say_status :warning, "Tag '#{tag}' is not present in the database (try `stickyflag update`)", :yellow unless options.quiet?
          bad_tag = true
          next
        end
      
        tag_ids << tag_id
      end
      return [] if bad_tag
    
      file_rows = @database[:tagged_files].where(:tag => tag_ids).group_by(:file).having{[[count(:*){}, tag_ids.count]]}
      if file_rows.empty?
        say_status :warning, "Requested combination of tags not found", :yellow unless options.quiet?
        return []
      end
    
      files = []
      file_rows.each do |row|
        file_id = row[:file]
        file = @database[:file_list].where(:id => file_id).get(:file_name)
        raise Thor::Error.new("ERROR: Could not get file_name for id saved in database (re-run `stickyflag update`)") unless file
      
        files << file
      end
    
      files
    end
  
    def tag_list
      @database[:tag_list].map { |r| r[:tag_name] }
    end
  end
end
