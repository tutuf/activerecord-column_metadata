require 'json'

module ActiveRecord
  class ColumnMetadata
    # Retrieves metadata stored in the database for +table_name+ as
    # [["col_name", {"key" => "val"}], ...]
    def self.to_a(table_name)
      res = ActiveRecord::Base.connection.query(<<-END_SQL, 'Get comments')
        SELECT a.attname,
               pg_catalog.col_description(a.attrelid, a.attnum)
          FROM pg_catalog.pg_attribute a
         WHERE a.attrelid = '#{table_name}'::regclass
           AND a.attnum > 0
           AND NOT a.attisdropped
      ORDER BY a.attname
      END_SQL
      res.map{ |tupple| [tupple.first, JSON.parse(tupple.last)] unless tupple.last.nil? }.compact
    end
  end
end