task :environment do
	require './lib/environment'
	require './lib/models'
end

namespace :db do
	task :migrate => :environment do
		require 'dm-migrations'
		DataMapper.auto_upgrade!
	end
	task :reset => :environment do
		require 'dm-migrations'
		DataMapper.auto_migrate!
	end
end

unless ENV['RACK_ENV'] == 'production'
	require 'rspec/core/rake_task'
	RSpec::Core::RakeTask.new(:spec)
	task :default => :spec
end

