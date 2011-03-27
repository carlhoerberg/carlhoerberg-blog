task :environment do
	require File.expand_path("../lib/environment", __FILE__)
	require File.expand_path("../lib/models", __FILE__)
end

namespace :db do
	task :migrate => :environment do
		require 'dm-migrations'
		DataMapper.auto_upgrade!
	end
end
task :import do
	require 'rss/1.0'
	require 'rss/2.0'
	require 'open-uri'

	source = "http://feeds.feedburner.com/devcarl?format=xml" 
	content = "" # raw content of rss feed will be loaded here
	open(source) do |s| content = s.read end
	rss = RSS::Parser.parse(content, false)
	rss.items.each do |i|
		Post.create(:title => i.title,
			    :body => i.description,
			    :posted => i.date)
	end
end

unless ENV['RACK_ENV'] == 'production'
	require 'rspec/core/rake_task'
	RSpec::Core::RakeTask.new(:spec)
	task :default => :spec
end

