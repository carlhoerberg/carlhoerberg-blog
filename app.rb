# encoding: UTF-8
require 'sinatra'
require 'haml'
require 'builder'
require 'yaml'

set :haml, :format => :html5, :escape_html => true
set :views, './views'
set :public, './public'

class ::Hash
  def method_missing(name)
    return self[name] if key? name
    self.each { |k,v| return v if k.to_s.to_sym == name }
    super.method_missing name
  end
end

get '/' do
	@posts = YAML.load_file 'posts.yml'
	@posts.sort_by! { |p| p.posted }.reverse!
	haml :index
end

get '/rss.xml' do
	content_type 'application/rss+xml'
	@posts = YAML.load_file 'posts.yml'
	@posts.sort_by! { |p| p.posted }.reverse!
	builder :rss
end

%w{pages posts}.each do |type| 
	get "/#{type}/:slug" do |slug|
		data = YAML.load_file "#{type}.yml"
		@post = data.select { |p| p['slug'] == slug }.first
		haml :post
	end
end

helpers do
	def replace_gist(html)
		html.gsub(/(http[s]?:\/\/gist.github.com\/[\d]+)[^#< ]*/, '<script src="\1.js"></script>')
	end
end
