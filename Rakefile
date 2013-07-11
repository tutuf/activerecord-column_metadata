require "bundler/gem_tasks"
require 'rspec/core'
require 'rspec/core/rake_task'

task :default => :spec

desc "Run all specs in spec directory"
RSpec::Core::RakeTask.new(:spec)

namespace :test do
  desc 'Build the test database'
  task :create_database do
    %x( createdb -U postgres activerecord-column_metadata_test )
  end

  desc 'Drop the test database'
  task :drop_database do
    %x( dropdb -U postgres activerecord-column_metadata_test )
  end

  desc 'Rebuild the test database'
  task :rebuild_database => [:drop_database, :create_database]
end