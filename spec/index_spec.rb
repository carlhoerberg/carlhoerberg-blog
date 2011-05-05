#encoding: UTF-8
require 'rspec'
require 'capybara'
require 'capybara/rspec'
require './app'

module YAML
	def load_file
		[{:slug => 'slug', :title => 'Title', :posted => Time.new, :body => 'body'}]
	end
end

describe "Index page" do
	include Capybara
  before do
    Capybara.app = Sinatra::Application.new
  end

  it "shows posts" do
    visit '/'
		page.should have_content 'Title'
		page.should have_content 'body'
  end
	it 'has comment link' do
	end
	it 'links to posts' do 
	end
	it 'includes gists' do
	end
	it 'has my social links' do
	end

end
