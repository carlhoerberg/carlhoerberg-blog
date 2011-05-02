# encoding: UTF-8
require 'sinatra'
require 'haml'
require 'builder'
require 'rdiscount'
require 'yaml'

set :haml, :format => :html5, :escape_html => true

before do 
	cache_control :public #, :max_age => 3600*24
	content_type :html, :charset => 'utf-8'
end

class ::Hash
  def method_missing(name)
    return self[name] if key? name
    self.each { |k,v| return v if k.to_s.to_sym == name }
    super.method_missing name
  end
end

get '/' do
	last_modified File.mtime('posts.yml')
	@posts = YAML.load_file 'posts.yml'
	@posts.sort_by! { |p| p.posted }.reverse!
	haml :index
end

get '/rss.xml' do
	content_type 'application/rss+xml', :charset => 'utf-8'
	last_modified File.mtime('posts.yml')
	@posts = YAML.load_file 'posts.yml'
	@posts.sort_by! { |p| p.posted }.reverse!
	builder :rss
end

get "/pages/:slug" do |slug|
	last_modified File.mtime("pages.yml")
	data = YAML.load_file "pages.yml"
	@page = data.select { |p| p['slug'] == slug }.first
	haml :page
end

get "/:slug" do |slug|
	last_modified File.mtime("posts.yml")
	data = YAML.load_file "posts.yml"
	@post = data.select { |p| p['slug'] == slug }.first
	haml :post
end

helpers do
	def replace_gist(html)
		html.gsub(/(http[s]?:\/\/gist.github.com\/[\d]+)[^#< ]*/, '<script src="\1.js"></script>')
	end
end
