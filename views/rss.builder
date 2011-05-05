xml.instruct! :xml, :version => '1.0'
xml.rss :version => "2.0" do
	xml.channel do
		xml.title "Carl Hörberg on development"
		xml.link "http://carlhoerberg.com/"
		@posts.each do |post|
			xml.item do
				xml.title post.title
				xml.link "http://carlhoerberg.com/#{post.slug}"
				xml.description replace_gist_with_link(markdown(post.body))
				xml.pubDate Time.parse(post.posted.to_s).rfc822()
				xml.guid "http://carlhoerberg.com/#{post.slug}"
			end
		end
	end
end
