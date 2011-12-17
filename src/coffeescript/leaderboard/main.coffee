
$(document).ready ->
  $.getJSON("/scores").then(draw_leaderboard)
  one_minute = 60000 

  setInterval(() ->
    $.getJSON("/scores").then(draw_leaderboard)
  ,one_minute)

leader_template = (vars, opacity) -> 
  """
  <div class="row" style="opacity: #{opacity};">
    <div class="six columns">
      <h2 class="rank">#{vars.rank}. #{vars.name}</h2>
    </div>

    <div class="one-and-a-half columns">
      <div class="#{vars.post_color} small gradient-box">
        <h3>#{vars.post_count}</h3>
        <small>Posts</small>
      </div>
    </div>

    <div class="one-and-a-half columns">
      <div class="#{vars.comment_color} small gradient-box">
        <h3>#{vars.comment_count}</h3>
        <small>Comments</small>
      </div>
    </div>


    <div class="one-and-a-half columns">
      <div class="#{vars.score_color} striped gradient-box">
        <h3>#{vars.score}</h3>
        <small>Total Score</small>
      </div>
    </div>
  </div>
  <hr/>
  """


get_median = (sorted_observations) ->
  len = sorted_observations.length
  return sorted_observations[0] if len == 1

  index = Math.floor(len/2)

  # avg middle numbers when even
  if len % 2 == 0
    mid1 = sorted_observations[index-1]
    mid2 = sorted_observations[index]
    (mid1 + mid2) / 2
  else 
    sorted_observations[index]

get_color = (num_items, median) ->
  console.log median

  return "blue" if median == 0 || isNaN(median)

  if num_items > median
    "green"
  else
    "blue"

add_if_missing = (array, item) ->
  array.push(item) if array.indexOf(item) == -1

draw_leaderboard = (scores) ->
  container = $("#leaderBoard")
  container.html("")

  html = ""

  post_counts = []
  comment_counts = []
  score_counts = []

  for blog_score in scores
    add_if_missing(post_counts, blog_score.posts)
    add_if_missing(comment_counts, blog_score.comments)
    add_if_missing(score_counts, blog_score.score)

  post_median = get_median(post_counts)
  comment_median = get_median(comment_counts)
  score_median = get_median(score_counts)

  for blog_score, i in scores
    row = {}
    row.rank = i+1
    row.name = blog_score.author

    row.post_color = get_color(blog_score.posts, post_median)
    row.comment_color = get_color(blog_score.comments, comment_median)
    row.score_color = get_color(blog_score.score, score_median)

    row.post_count = blog_score.posts
    row.comment_count = blog_score.comments
    row.score = blog_score.score

    opacity = "#{1-(i*0.1)}"
    html += leader_template(row, opacity)

  container.append $(html)

