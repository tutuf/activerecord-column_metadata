require 'spec_helper'

describe ActiveRecord::ColumnMetadata do
  it 'should have a version number' do
    ActiveRecord::ColumnMetadata::VERSION.should_not be_nil
  end

  def get_comments(table_name)
    ActiveRecord::Base.connection.query(<<-END_SQL, 'Get comments')
      SELECT a.attname,
             pg_catalog.col_description(a.attrelid, a.attnum)
        FROM pg_catalog.pg_attribute a
       WHERE a.attrelid = '#{table_name}'::regclass
         AND a.attnum > 0
         AND NOT a.attisdropped
    ORDER BY a.attname
    END_SQL
  end

  class CreateTableMigration < ActiveRecord::Migration
    def self.up
      create_table(:people) do |t|
        t.string :name
        t.column_metadata(:name, {:something => true})
      end
    end
  end
  
  class AddColumnMigration < ActiveRecord::Migration
    def self.up
      add_column :people, :surname, :string, :metadata => {full_text_search: "double_metaphone"}
    end
  end

  describe 'write should add JSON in comment' do
    it 'with create_table' do
      CreateTableMigration.up
      res = get_comments("people")
      expect(res).to include( ["name",'{"something":true}'])
    end
  
    it 'with add_collumn' do
      CreateTableMigration.up
      AddColumnMigration.up
      res = get_comments("people")
      expect(res).to include( ['surname', '{"full_text_search":"double_metaphone"}'])
    end
  end
  
  describe 'read' do
    it '#to_a should return a column comments as an array of arrays' do
      CreateTableMigration.up
      res = ActiveRecord::ColumnMetadata.to_a(:people)
      res.should == [["name", {"something" => true}]]
    end
  end 
end
