require 'rubygems'
require 'bundler/setup'
require 'open-uri'
require 'sinatra'
require 'json'
require 'simple-rss'

# Points to assign to posts/comments
POINTS = {
  :post => 10,
  :comment => 1 
}

def parse_feed(url)
  SimpleRSS.parse open(url)
end

def format_author_name(name) 
  author = name
  index = name.index "http"
  author = name[0..index-1] unless index.nil?
  author.split(" ")[0]
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
    data[:score]  = calc_score(data[:posts], data[:comments])
    data
  end.sort { |a, b| b[:score] <=> a[:score] }
end


def count_comments(comments_link)
  feed = parse_feed comments_link
  feed.entries.length
end


# Public Blog Feed to Use
BLOG = "http://dev.bizo.com/feeds/posts/default"


# Routes
get "/scores" do 
  feed = parse_feed BLOG
  scores = score_bloggers(feed.entries)
  content_type :json
  scores.to_json
end

get "/" do
  File.read(File.join('public', 'index.html'))
end  
