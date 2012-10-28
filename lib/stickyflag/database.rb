# -*- encoding : utf-8 -*-
require 'thread'
require 'rdbi'
if RUBY_PLATFORM == 'java'
  require 'rdbi-driver-jdbc'
  require 'jdbc/sqlite3'
  
  # Load this in so it gets detected
  org.sqlite.JDBC
else
  require 'rdbi-driver-sqlite3'
end

# Patch in some methods that will error-check our most common cases of fetch
# and return
class RDBI::Database
  def get_first_value(*args)
    result = execute(*args)
    return nil if result.nil?
    
    row_fetch = result.fetch
    return nil if row_fetch == []
    
    first_row = row_fetch[0]
    return nil if first_row == []
    
    first_row[0]
  end
  
  def selects_any_rows?(*args)
    result = execute(*args)
    return nil if result.nil?
    
    row_fetch = result.fetch
    return false if row_fetch == []
    
    first_row = row_fetch[0]
    return false if first_row == []
    
    true
  end
end

module StickyFlag
  module Database
    def load_database
      @database.disconnect if @database
      
      if RUBY_PLATFORM == 'java'
        rdbi_path = "sqlite:#{database_path}"
        rdbi_driver = :JDBC
      else
        rdbi_path = database_path
        rdbi_driver = :SQLite3
      end
      
      @database = RDBI.connect(rdbi_driver, :database => rdbi_path)
      raise Thor::Error.new("ERROR: Could not create database at '#{database_path}'") if @database.nil?
      
      create_tables
      
      # Do not do automatic cleanup from the RSpec test suite; this registers
      # dozens of at_exit hooks and crashes Ruby
      unless ENV['RSPEC_TESTING']
        puts "CALLING FROM #{caller.join('\n')}"
        at_exit { @database.disconnect }
      end
    end
  
    def create_tables
      @database.execute <<-SQL
        create table if not exists tag_list ( 
          tag_name varchar(65535),
          id integer primary key autoincrement );
      SQL
      @database.execute <<-SQL
        create table if not exists file_list ( 
          file_name varchar(65535),
          id integer primary key autoincrement );
      SQL
      @database.execute <<-SQL
        create table if not exists tagged_files ( 
          file integer,
          tag integer,
          id integer primary key autoincrement );
      SQL
    end
  
    def drop_tables
      @database.execute "drop table tag_list;"
      @database.execute "drop table file_list;"
      @database.execute "drop table tagged_files;"
    end
  
    def get_tag_id(tag)
      tag_id = @database.get_first_value "select id from tag_list where tag_name = ?", tag
      unless tag_id
        @database.execute "insert into tag_list ( tag_name ) values ( ? )", tag        
        tag_id = @database.get_first_value "select last_insert_rowid()"
      end
    
      tag_id
    end
  
    def get_file_id(file_name)
      file_id = @database.get_first_value "select id from file_list where file_name = ?", file_name
      unless file_id
        @database.execute "insert into file_list ( file_name ) values ( ? )", file_name
        file_id = @database.get_first_value "select last_insert_rowid()"
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
      
        file_id = get_file_id file      
        tags.each do |tag|
          tag_id = get_tag_id tag
          @database.execute "insert into tagged_files ( file, tag ) values ( ?, ? )", file_id, tag_id
        end
      end
    end
  
    def set_database_tag(file_name, tag)
      # Don't put in multiple entries for the same tag
      file_id = get_file_id file_name
      tag_id = get_tag_id tag
    
      return if @database.selects_any_rows? "select id from tagged_files where file = ? and tag = ?", file_id, tag_id    
      @database.execute "insert into tagged_files ( file, tag ) values ( ?, ? )", file_id, tag_id
    end
  
    def unset_database_tag(file_name, tag)
      file_id = get_file_id file_name
      tag_id = get_tag_id tag
      @database.execute "delete from tagged_files where file = ? and tag = ?", file_id, tag_id
    
      # See if that was the last file with this tag, and delete it if so
      unless @database.selects_any_rows? "select id from tagged_files where tag = ?", tag_id
        @database.execute "delete from tag_list where id = ?", tag_id
      end
    end
  
    def clear_database_tags(file_name)
      file_id = get_file_id file_name
      @database.execute "delete from tagged_files where file = ?", file_id
    
      # That operation might have removed the last instance of a tag, clean up
      # the tag list
      tag_result = @database.execute "select id from tag_list"
      tag_rows = tag_result.fetch(:all)
      
      tag_rows.each do |row|
        raise Thor::Error.new("INTERNAL ERROR: Database row error in tag_list") if row.empty?
        tag_id = row[0]
        
        unless @database.selects_any_rows? "select * from tagged_files where tag = ?", tag_id
          @database.execute "delete from tag_list where id = ?", tag_id
        end
      end
    end
  
    def files_for_tags(tags)
      # Map tags to tag IDs, but don't add any missing tags
      bad_tag = false
      tag_ids = []
      tags.each do |tag|
        tag_id = @database.get_first_value "select id from tag_list where tag_name = ?", tag
        unless tag_id
          say_status :warning, "Tag '#{tag}' is not present in the database (try `stickyflag update`)", :yellow unless options.quiet?
          bad_tag = true
          next
        end
      
        tag_ids << tag_id
      end
      return [] if bad_tag
    
      file_result = @database.execute "select file from tagged_files where tag in ( #{tag_ids.join(', ')} ) group by file having count(*) = #{tag_ids.count}"
      file_rows = file_result.fetch(:all)
      
      if file_rows.empty?
        say_status :warning, "Requested combination of tags not found", :yellow unless options.quiet?
        return []
      end
    
      files = []
      file_rows.each do |row|
        file_id = row[0]        
        file = @database.get_first_value "select file_name from file_list where id = ?", file_id
        raise Thor::Error.new("ERROR: Could not get file_name for id saved in database (re-run `stickyflag update`)") unless file
      
        files << file
      end
    
      files
    end
  
    def tag_list
      tags = []
      @database.execute("select tag_name from tag_list").fetch(:all).each do |row|
        tags << row[0] unless row.empty?
      end
      
      tags
    end
  end
end
