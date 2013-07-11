# ActiveRecord::ColumnMetadata

Store metadata about columns in the database, as comments on columns (advanced PostgreSQL feature)

## Installation

Add this line to your application's Gemfile:

    gem 'activerecord-column_metadata'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install activerecord-column_metadata

## Usage

In a migration:

    create_table(:cars) do |t|
      t.string :name
      t.string :manufacturer
      t.string :model
    
      t.boolean :4wd
      t.boolean :abs
      t.boolean :airbag
      t.boolean :gps
      t.boolean :music_player
    
      [:4wd, :abs, :airbag, :gps, :music_player].each do |extra|
        t.column_metadata(extra, {extra: true})
      end
    end

or

    add_column :cars, :aircondition, :boolean, metadata: {extra: true}

And then you can say in the model:

    class Car < ActiveRecord::Base
      def self.extras
        ActiveRecord::JsonMetadata.to_a("cars").select do |arr|
          column_name, metadata = arr
          column_name if metadata["extra"] == true
        end
      end
    end

## Rationale

In the above example you could hardcode extras in the model:

    class Car < ActiveRecord::Base
      def self.extras
        [:4wd, :abs, :airbag, :gps, :music_player]
      end
    end

But what will happen when you have to add or remove an extra? You have to edit two files: migration and the corresponding ActiveRecord model. Unnecessary repetition
causes brain injury.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
