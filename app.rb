# encoding: UTF-8
require 'sinatra'
require 'haml'
require 'builder'
require 'rdiscount'
require 'yaml'

set :haml, :format => :html5, :escape_html => true

configure :production do 
	require 'newrelic_rpm'
	before do 
		if request.host != 'carlhoerberg.com'
			redirect "http://carlhoerberg.com#{request.path}", 301 
		end
		cache_control :public, :max_age => 3600 
	end
end

before do 
	content_type :html, :charset => 'utf-8'
	@title = "Carl Hörberg on development"
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
	halt 404 if @page.nil?
	@title = @page.title
	haml :page
end

# legacy url from old blog
get "/17315192" do
	redirect url('/aspnet-mvc-and-the-microsoft-chart-controls-in-net-40'), 301
end

get "/:slug" do |slug|
	last_modified File.mtime("posts.yml")
	data = YAML.load_file "posts.yml"
	@post = data.select { |p| p.slug == slug }.first
	halt 404 if @post.nil?
	@title = @post.title
	haml :post
end

helpers do
	def replace_gist_with_script(html)
		html.gsub(/(http[s]?:\/\/gist.github.com\/[\d]+)[^#< ]*/,
							'<script src="\1.js"></script>')
	end

	def replace_gist_with_link(html)
		html.gsub(/(http[s]?:\/\/gist.github.com\/[\d]+)[^#< ]*/, 
							'See the code here: <a href="\1">\1</a>')
	end
end

class ::Hash
	def method_missing(name)
		return self[name] if key? name
		self.each { |k,v| return v if k.to_s.to_sym == name }
		super.method_missing name
	end
end
