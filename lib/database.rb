# -*- encoding : utf-8 -*-
require 'sqlite3'

module Database
  # NB: If you update this function significantly, you may have to change the
  # corresponding stub in the specs.
  def load_database
    @database = SQLite3::Database.new database_path
    if @database.nil?
      raise Thor::Error.new("ERROR: Could not create database at '#{database_path}'")
    end
    
    create_tables
    at_exit { @database.close }
  end
  
  def create_tables
    @database.execute <<-SQL
      create table if not exists tag_list ( 
        tag_name text,
        id integer primary key autoincrement );
    SQL
    @database.execute <<-SQL
      create table if not exists file_list ( 
        file_name text,
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
    @database.execute "drop table tag_list"
    @database.execute "drop table file_list"
    @database.execute "drop table tagged_files"
  end
  
  def get_tag_id(tag)
    tag_id = @database.get_first_value "select id from tag_list where tag_name = ?", [ tag ]
    unless tag_id
      @database.execute "insert into tag_list ( tag_name ) values ( ? )", [ tag ]
      tag_id = @database.last_insert_row_id
    end
    
    tag_id
  end
  
  def get_file_id(file_name)
    file_id = @database.get_first_value "select id from file_list where file_name = ?", [ file_name.to_s ]
    unless file_id
      @database.execute "insert into file_list ( file_name ) values ( ? )", [ file_name.to_s ]
      file_id = @database.last_insert_row_id
    end
    
    file_id
  end
  
  def update_database_from_files(directory = '.')
    drop_tables
    create_tables
    
    Pathname.glob(File.join(directory, '**', "*{#{available_tagging_extensions.join(',')}}")).each do |file|
      begin
        tags = get_tags_for file
      rescue Thor::Error
        # Just skip this file, then, don't error out entirely
        say_status :warning, "Could not read tags from '#{file}', thought we should be able to"
        next
      end
      
      file_id = get_file_id file      
      tags.each do |tag|
        tag_id = get_tag_id tag
        @database.execute "insert into tagged_files ( file, tag ) values ( ?, ? )", [ file_id, tag_id ]
      end
    end
  end
  
  def set_database_tag(file_name, tag)
    # Don't put in multiple entries for the same tag
    file_id = get_file_id file_name
    tag_id = get_tag_id tag
    
    rows = @database.execute "select id from tagged_files where file = ? and tag = ?", [ file_id, tag_id ]
    return unless rows.empty?
    
    @database.execute "insert into tagged_files ( file, tag ) values ( ?, ? )", [ file_id, tag_id ]
  end
  
  def unset_database_tag(file_name, tag)
    file_id = get_file_id file_name
    tag_id = get_tag_id tag
    @database.execute "delete from tagged_files where file = ? and tag = ?", [ file_id, tag_id ]
    
    # See if that was the last file with this tag, and delete it if so
    files_with_tag = @database.execute "select id from tagged_files where tag = ?", [ tag_id ]
    if files_with_tag.empty?
      @database.execute "delete from tag_list where id = ?", [ tag_id ]
    end
  end
  
  def clear_database_tags(file_name)
    file_id = get_file_id file_name
    @database.execute "delete from tagged_files where file = ?", [ file_id ]
    
    # That operation might have removed the last instance of a tag, clean up
    # the tag list
    tag_rows = @database.execute "select id from tag_list"
    tag_rows.each do |row|
      if row.empty?
        raise Thor::Error.new("ERROR: Somehow got a bum row back from the tag_list")
      end
      
      rows = @database.execute "select * from tagged_files where tag = ?", [ row[0] ]
      if rows.empty?
        @database.execute "delete from tag_list where id = ?", [ row[0] ]
      end
    end
  end
  
  def files_for_tags(tags)
    # Map tags to tag IDs, but don't add any missing tags
    tag_ids = []
    tags.each do |tag|
      tag_id = @database.get_first_value "select id from tag_list where tag_name = ?", [ tag ]
      unless tag_id
        say_status :warning, "Tag '#{tag}' is not present in the database (try `stickyflag update`)", :yellow
        next
      end
      
      tag_ids << tag_id
    end
    
    rows = @database.execute "select file from tagged_files where tag in ( #{tag_ids.join(', ')} ) group by file having count(*) = #{tag_ids.count}"
    if rows.empty?
      say_status :warning, "Requested combination of tags not found", :yellow
      return
    end
    
    files = []
    rows.each do |row|
      file = @database.get_first_value "select file_name from file_list where id = ?", [ row[0] ]
      unless file
        raise Thor::Error.new("ERROR: Could not get file_name for id saved in database (re-run `stickyflag update`)")
      end
      
      files << file
    end
    
    files
  end
  
  def tag_list
    @database.execute("select tag_name from tag_list").map { |r| r[0] }
  end
end
