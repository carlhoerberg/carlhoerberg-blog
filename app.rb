# encoding: UTF-8
require 'sinatra'
require 'haml'
require 'builder'
require 'redcarpet'
require 'yaml'
require 'open-uri'
require 'json'
require 'em-http'

set :haml, :format => :html5, :escape_html => true

configure :production do 
	require 'newrelic_rpm'
	before do 
		if request.host != 'carlhoerberg.com'
			redirect "http://carlhoerberg.com#{request.path}", 301 
		end
		cache_control :public, :max_age => 24 * 3600
	end
end
configure :development do
  before do
    cache_control :no_store
  end
end

before do 
	content_type :html, :charset => 'utf-8'
	@title = "Carl Hörberg on development"
end

get '/' do
	last_modified File.mtime('posts.yml')
	@posts = YAML.load_file 'posts.yml'
	@posts = @posts.sort_by { |p| p.posted }.reverse
	haml :index
end

get '/rss.xml' do
	last_modified File.mtime('posts.yml')
	content_type 'application/rss+xml', :charset => 'utf-8'
	@posts = YAML.load_file 'posts.yml'
	@posts = @posts.sort_by { |p| p.posted }.reverse
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

class Log
  def request(client, head, body)
    [head, body]
  end
  def response(resp)
  end
end

class JSONify
  def response(resp)
    resp.response = JSON.parse(resp.response)
  end
end
get '/github' do
  content_type :text
  stream(:keep_open) do |out|
    http = EventMachine::HttpRequest.new("https://api.github.com")
    http.use JSONify
    http.use Log
    req = http.get :keepalive => true, :path => "/users/carlhoerberg/repos"
    @i = 0
    req.callback do 
      repos = req.response
      repos.select{|r| r['fork'] == true}.each do |r|
        repo_req = http.get :path=> URI.parse(r['url']).path, :keepalive => true
        repo_req.callback do
          repo = repo_req.response
          pulls_url = "#{repo['parent']['url']}/pulls?state=closed"
          get_pulls(http, pulls_url, out)
        end
      end
    end
  end
end

def get_pulls(http, pulls_url, out)
  uri = URI.parse(pulls_url)
  pulls_req = http.get :path => uri.path, :query => uri.query, :keepalive => true
  @i += 1
  pulls_req.callback do
    pulls = pulls_req.response
    my_pulls = pulls.select { |p| p['user']['login'] == 'carlhoerberg' }
    my_pull_urls = my_pulls.collect { |p| p['html_url'] }
    my_pull_urls.each { |u| out << u << "\n" }
    next_url = next_page pulls_req.response_header['LINK']
    @i -= 1
    if next_url
      get_pulls(http, next_url, out) 
    elsif @i == 0
      out.close
    end
  end
  pulls_req.errback do
    @i -= 1
    if @i == 0
      out.close
    end
  end
end

def next_page(link)
  if link
    if nxt = link.split(',').find { |l| l.end_with? 'rel="next"'} 
      nxt.sub /^<(.*)>.*$/, '\1'
    end
  end
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
  def gsub_gists(html)
    html.gsub /(http[s]?:\/\/gist.github.com\/[\d]+)[^#< ]*/ do |match|
      uri = URI.parse "#{$1}.js".gsub(/http:/, "https:")
      js = uri.read
      js.gsub(/document\.write\('(.*)/, '\1').gsub(/\'\)$/, '').gsub(/\\n/, "\n").gsub(/\\["']/, '"').gsub(/\\\//, "/")
    end
  end
end

class ::Hash
  def method_missing(name)
    return self[name] if key? name
    self.each { |k,v| return v if k.to_s.to_sym == name }
    super.method_missing name
  end
end
