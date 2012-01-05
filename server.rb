require 'rubygems'
require 'bundler/setup'
require 'open-uri'
require 'sinatra'
require 'json'
require 'simple-rss'
require 'yaml'

YAML_CONFIG = YAML.load_file("./config.yaml")
BLOG        = YAML_CONFIG["blogger_feed"] 
GRAVATARS   = YAML_CONFIG["gravatars"]

GA_USER     = ENV['GA_USER']
GA_PASSWORD = ENV['GA_PASSWORD']

GA_PROPERTY = YAML_CONFIG["google_analytics_property"]

# Points to assign to posts/comments
POINTS = {
  :post    => YAML_CONFIG["points"]["post"],
  :comment => YAML_CONFIG["points"]["comment"]
}


module GoogleAnalytics
  require 'garb'

  class ViewsReport
    extend Garb::Model

    metrics :unique_pageviews
    dimensions :page_path
  end

  class Api
    def initialize(login, password)
      Garb::Session.login(login, password)
      @profile = Garb::Management::Profile.all.detect {|p| p.web_property_id == GA_PROPERTY }
    end

    def get_views
      @profile.views_report.to_a
    end
  end
end


def parse_feed(url)
  SimpleRSS.parse open(url)
end

def format_author_name(name) 
  # rss parser ends up with junk at end of name
  # returns only the first name of author
  author = name.gsub(/http.*/, "").gsub("noreply@blogger.com", "")
  author.split(" ")[0].capitalize
end


def get_gravatar(author)
  hash = GRAVATARS[author] || "default"
  "https://secure.gravatar.com/avatar/#{hash}?s=140"
end


def calc_score(num_posts, num_comments) 
  score = 0
  score += (num_posts * POINTS[:post])
  score += (num_comments * POINTS[:comment])
  score
end


def score_bloggers(entries)
  authors = {} 

  entries.each do |entry|
    author = format_author_name(entry.author)
    authors[author] ||= {:posts => 0, :comments => 0, :score => 0}
    authors[author][:posts] += 1 

    comments_link = entry[:"link+replies"]
    num_comments = count_comments(comments_link)
    authors[author][:comments] = num_comments
  end


  authors.keys.map do |author|
    data = authors[author]
    data[:author] = author
    data[:gravatar] = get_gravatar(author)
    data[:score]  = calc_score(data[:posts], data[:comments])
    data
  end.sort { |a, b| b[:score] <=> a[:score] }
end


def score_pageviews(posts, post_analytics)
  author_pageviews_map = {}

  posts.each do |post|
    # put author in map
    author = format_author_name(post.author)
    author_pageviews_map[author] ||= 0

    # get pageviews for entry
    path = post[:"link+alternate"]
    
    # filter out root "/" since it will always match
    analytics = post_analytics.detect { |analytics| path.include?(analytics.page_path) && analytics.page_path != "/" }
    author_pageviews_map[author] += analytics.unique_pageviews.to_i unless analytics.nil?
  end

  p author_pageviews_map
  author_pageviews_map
end


def count_comments(comments_link)
  feed = parse_feed comments_link
  feed.entries.length
end


get "/scores" do 
  puts "Parsing blogger rss feed..."
  feed = parse_feed BLOG
  scores = score_bloggers(feed.entries)

  content_type :json
  scores.to_json
end

get "/views" do
  puts "Pulling google analytics..."
  profile = GoogleAnalytics::Api.new(GA_USER, GA_PASSWORD)
  views = profile.get_views

  puts "Parsing blogger rss feed..."
  feed = parse_feed BLOG
  entries = feed.entries

  content_type :json
  score_pageviews(entries, views).to_json
end

get "/" do
  File.read(File.join('public', 'index.html'))
end  
