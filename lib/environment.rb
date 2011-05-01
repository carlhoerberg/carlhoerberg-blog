require 'dm-core'

if ENV['RACK_ENV'] == 'production'
	DataMapper.setup(:default, ENV['DATABASE_URL'])
else
	DataMapper::Logger.new($stdout, :debug)
	DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/db.sqlite")
end
