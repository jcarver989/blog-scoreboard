
$(document).ready ->
  $.getJSON("/scores").then(draw_leaderboard)
  one_minute = 60000 

  setInterval(() ->
    $.getJSON("/scores").then(draw_leaderboard)
  ,one_minute)

leader_template = (vars, is_winner) -> 
  """
  <div style="display: none;">
    <div class="row #{if is_winner then "winner" else ""}">
      <div class="three-quarters column">
        <h2 class="rank">#{vars.rank}.</h2>
      </div>

      <div class="one-and-a-half columns">
        <img class="gravatar" src="#{vars.gravatar}" />
      </div>

      <div class="three columns">
        <h2>#{vars.name}</h2>
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
        <div class="#{vars.score_color} large gradient-box">
          <h3>#{vars.score}</h3>
          <small>Total Score</small>
        </div>
      </div>
    </div>
    <hr/>
  </div>
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

  nodes = [] 
  html = $("<div>")

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
    row.gravatar = blog_score.gravatar

    row.post_color = get_color(blog_score.posts, post_median)
    row.comment_color = get_color(blog_score.comments, comment_median)
    row.score_color = get_color(blog_score.score, score_median)

    row.post_count = blog_score.posts
    row.comment_count = blog_score.comments
    row.score = blog_score.score

    is_winner = i == 0
    node = $(leader_template(row, is_winner))
    nodes.push node
    html.append node

  container.append html

  delay = 0
  for node in nodes.slice(0).reverse()
    node.delay(delay).slideDown(200)
    delay += 3000
