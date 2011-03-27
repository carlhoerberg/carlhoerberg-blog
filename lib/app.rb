# encoding: UTF-8
require 'sinatra'
require 'haml'
require 'builder'
require File.expand_path("../models", __FILE__)

set :haml, :format => :html5, :escape_html => true
set :views, File.expand_path("../../views", __FILE__)
set :public, File.expand_path("../../public", __FILE__)

helpers do
  def protected!
    unless authorized?
      response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
      throw(:halt, [401, "Not authorized\n"])
    end
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [ENV['bloguser'], ENV['blogpassword']]
  end

	def replace_gist(html)
					html.gsub(/^(http[s]?:\/\/gist.github.com\/[\d]+)$/, 
										"<script src='\1.js'></script>") 
	end
end


get '/' do
	@posts = Post.all(:order => [:posted.desc])
	haml :index
end

get '/posts/:slug' do |slug|
	@post = Post.get(slug)
	haml :post
end

get '/rss.xml' do
	content_type 'application/rss+xml'
	@posts = Post.all(:order => [:posted.desc])
	builder :rss
end

get '/edit/:slug' do
				protected!
				@post = Post.get(params[:slug])
				haml :edit
end

post '/edit/:slug' do
				protected!
				@post = Post.get(params[:slug])
				@post.update_attributes params
				@post.save ? redirect(url('/posts/'+@post.slug)) : haml(:edit)
end

get '/new' do
				protected!
				@post = Post.new(:posted => DateTime.now)
				haml :edit
end

post '/new' do
				protected!
				@post = Post.new(params)
				@post.save ? redirect(url('/posts/'+@post.slug)) : haml(:edit)
end

