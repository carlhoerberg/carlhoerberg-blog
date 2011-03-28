task :environment do
	require File.expand_path("../lib/environment", __FILE__)
	require File.expand_path("../lib/models", __FILE__)
end

namespace :db do
	task :migrate => :environment do
		require 'dm-migrations/migration_runner'
		require './migrations'
		migrate_up!
	end

	task :upgrade => :environment do
		require 'dm-migrations'
		DataMapper.auto_upgrade!
	end
end

unless ENV['RACK_ENV'] == 'production'
	require 'rspec/core/rake_task'
	RSpec::Core::RakeTask.new(:spec)
	task :default => :spec
end

