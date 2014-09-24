require 'active_record/connection_adapters/abstract/schema_definitions'
require 'active_record/connection_adapters/abstract/schema_statements'
require 'active_record/connection_adapters/postgresql_adapter'

module ActiveRecord
  module ConnectionAdapters
    class TableDefinition
      module ColumnMetadata
        def column_metadata(column, hash)
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

      include ColumnMetadata
    end

    module SchemaStatements
      # works only with databases that support comments on columns
      def create_table(table_name,options={},&block)
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
        table_definition.comments.each{ |c| write_json_comment(table_name, c.to_a.first, c.to_a.last) } if table_definition.comments
      end
    end

    class PostgreSQLAdapter < AbstractAdapter
      def add_column_with_metadata(*args)
        add_column_without_metadata(*args)
        options = args.extract_options!
        write_json_comment(args[0], args[1], options[:metadata])
      end
      alias_method_chain :add_column, :metadata

      def column_metadata(table_name, column_name, metadata)
        write_json_comment(table_name, column_name, metadata)
      end

      def write_json_comment(table_name, column_name, comment)
        execute "COMMENT ON COLUMN #{quote_table_name(table_name)}.#{quote_column_name(column_name)} IS #{quote(comment.to_json)}" unless comment.blank?
      end
    end
  end
end
