
$(document).ready ->
  spinner_id = rotate_spinner()
  one_minute = 60000

  container = $("#leaderBoard")
  screens = [
    ["/scores", draw_leaderboard],
    ["/views", draw_pageviews_leaderboard]
  ]
  
  # set at end so we wrap around & start at 0
  current_screen = 0 

  draw_screen = (clear_spinner = false) ->
    current_screen = current_screen % screens.length
    [url, draw_func] = screens[current_screen]

    $.getJSON(url).then((result) ->
      window.clearInterval(spinner_id) if clear_spinner
      $("#loading").fadeOut(200, () ->
        $("#loading").remove()
      )

      container.fadeOut(200, () ->
        container.empty()
        container.fadeIn(200, () ->
          draw_func(container, result)
        )
      )

      current_screen += 1
    )

  draw_screen(true)
  setInterval(draw_screen, one_minute)


rotate_spinner = ->
  count = 0

  rotate = () ->
    spinner = document.getElementById('spinner')
    spinner.style.MozTransform = 'rotate('+count+'deg)'
    spinner.style.WebkitTransform = 'rotate('+count+'deg)'
    count = 0 if count == 360
    count+= 45

  window.setInterval(rotate, 100)
  

leader_template = (vars, is_winner) -> 
  """
  <div style="display: none">
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
    median = (mid1 + mid2) / 2
    median
  else 
    median = sorted_observations[index]
    median

get_color = (num_items, median) ->
  return "blue" if median == 0 || isNaN(median)

  if num_items > median
    "green"
  else if num_items == median
    "blue"
  else
    "red"

draw_pageviews_leaderboard = (container, scores) ->
  $("#title").text("Pageviews Leaderboard")

  graph = $("<div id='barchart' style='width:#{container.innerWidth()}px; height: 500px;'></div>")
  container.append graph

  mapped_scores = ([author, pageviews] for author, pageviews of scores)
  mapped_scores.sort (a, b) ->
    b[1] - a[1]


  c = new Charts.BarChart('barchart', {
    bar_color : "90-#005e7d-#00a5dc",
    bar_width: 115
    bar_margin: 20
    y_padding: 60
    rounding: 10

    x_label_color: "#fff"
    x_label_size: 30 

    y_label_color: "#fff"
    y_label_size: 30 
  })

  for score in mapped_scores
    c.add {
      label: score[0]
      value: score[1]
    }

  c.draw()

draw_leaderboard = (container, scores) ->
  $("#title").text("Blog Post Leaderboard")

  nodes = [] 
  html = $("<div>")

  post_counts = []
  comment_counts = []
  score_counts = []

  for blog_score in scores
    post_counts.push blog_score.posts
    comment_counts.push blog_score.comments
    score_counts.push blog_score.score

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
