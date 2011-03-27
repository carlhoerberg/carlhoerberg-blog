source "http://rubygems.org"

gem "sinatra"
gem "haml"
gem "datamapper"
gem "builder"
gem "rdiscount"

group :production do 
	gem "dm-postgres-adapter"
	gem "newrelic_rpm"
	gem "rpm_contrib"
	gem "heroku"
	gem "exceptional"
end

group :development do
	gem "dm-sqlite-adapter"
	gem "sinatra-reloader"
end

group :test do
	gem "capybara"
	gem "rspec"
	gem "dm-sweatshop"
	gem "faker"
end
