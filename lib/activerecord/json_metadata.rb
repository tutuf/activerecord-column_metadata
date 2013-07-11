require 'active_record'
require 'active_record/connection_adapters/table_definition'
require "activerecord/json_metadata/version"

module Activerecord
  class ColumnMetadata
    # Retrieves metadata stored as column comments in the database
    # {"col_name" => "JSON_encoded_metadata"}
    def self.to_hash(table_name)
      # [["col_name", "JSON_encoded_metadata"], ...]
      res = ActiveRecord::Base.connection.query(<<-END_SQL, 'Get comments')
        SELECT a.attname,
               pg_catalog.col_description(a.attrelid, a.attnum)
          FROM pg_catalog.pg_attribute a
         WHERE a.attrelid = '#{table_name}_data'::regclass
           AND a.attnum > 0
           AND NOT a.attisdropped
      ORDER BY a.attname
      END_SQL
      res.inject({}) do |acc, tuple|
        acc[tuple.first] = JSON.parse(tupple.last)
        acc
      end
    end
  end
  
  module ConnectionAdapters
    class TableDefinition
      module JsonMetadata
        def json_metadata(column, hash)
          add_comment(column, hash)
        end
      
        def add_comment(column, comment)
          @comments ||= []
          @comments << [column, comment]
        end
    
        def comments
          @comments
        end
      end
      
      include JsonMetadata
    end
    
    module SchemaStatements
      # will work only with PostgreSQL
      def create_table_with_column_comments(table_name,options={},&block)
        table_definition = TableDefinition.new(self)
        table_definition.primary_key(options[:primary_key] || Base.get_primary_key(table_name)) unless options[:id] == false

        yield table_definition if block_given?

        if options[:force] && table_exists?(table_name)
          drop_table(table_name, options)
        end

        create_sql = "CREATE#{' TEMPORARY' if options[:temporary]} TABLE "
        create_sql << "#{quote_table_name(table_name)} ("
        create_sql << table_definition.to_sql
        create_sql << ") #{options[:options]}"
        execute create_sql
        table_definition.comments.each do|c| 
          execute "COMMENT ON COLUMN #{quote_table_name(table_name)}.#{quote_column_name(c.to_a.first)} IS #{quote(c.to_a.last.to_json)}"
        end if table_definition.comments
      end
      
      alias_method_chain :create_table, :column_comments
    end
  end
  
  include JsonMetadata
end
