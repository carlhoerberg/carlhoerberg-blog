require 'dm-core'
require 'dm-types'
require 'dm-validations'
require 'dm-constraints'

class Post
	include DataMapper::Resource
	property :slug, String, :key => true, :length => 255
	property :title, String, :required => true, :length => 255
	property :body, Text, :required => true, :lazy => false
	property :posted, DateTime
end
