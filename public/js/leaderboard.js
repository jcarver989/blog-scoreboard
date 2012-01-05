    var global =  window

if (global.module == undefined) {
  global.module = function(name, body) {
    var exports = global[name]
    if (exports == undefined) {
    global[name] = exports = {}
    }
    body(exports)
  }
}


    module('Leaderboard', function(exports) {
      var draw_leaderboard, draw_pageviews_leaderboard, get_color, get_thirds, leader_template, rotate_spinner;

$(document).ready(function() {
  var container, current_screen, draw_screen, one_minute, screens, spinner_id;
  spinner_id = rotate_spinner();
  one_minute = 60000;
  container = $("#leaderBoard");
  screens = [["/scores", draw_leaderboard], ["/views", draw_pageviews_leaderboard]];
  current_screen = 0;
  draw_screen = function(clear_spinner) {
    var draw_func, url, _ref;
    if (clear_spinner == null) clear_spinner = false;
    current_screen = current_screen % screens.length;
    _ref = screens[current_screen], url = _ref[0], draw_func = _ref[1];
    return $.getJSON(url).then(function(result) {
      if (clear_spinner) window.clearInterval(spinner_id);
      $("#loading").fadeOut(200, function() {
        return $("#loading").remove();
      });
      container.fadeOut(200, function() {
        container.empty();
        return container.fadeIn(200, function() {
          return draw_func(container, result);
        });
      });
      return current_screen += 1;
    });
  };
  draw_screen(true);
  return setInterval(draw_screen, one_minute);
});

rotate_spinner = function() {
  var count, rotate;
  count = 0;
  rotate = function() {
    var spinner;
    spinner = document.getElementById('spinner');
    spinner.style.MozTransform = 'rotate(' + count + 'deg)';
    spinner.style.WebkitTransform = 'rotate(' + count + 'deg)';
    if (count === 360) count = 0;
    return count += 45;
  };
  return window.setInterval(rotate, 100);
};

leader_template = function(vars, is_winner) {
  return "<div style=\"display: none\">\n  <div class=\"row " + (is_winner ? "winner" : "") + "\">\n    <div class=\"three-quarters column\">\n      <h2 class=\"rank\">" + vars.rank + ".</h2>\n    </div>\n\n    <div class=\"one-and-a-half columns\">\n      <img class=\"gravatar\" src=\"" + vars.gravatar + "\" />\n    </div>\n\n    <div class=\"three columns\">\n      <h2>" + vars.name + "</h2>\n    </div>\n\n    <div class=\"one-and-a-half columns\">\n      <div class=\"" + vars.post_color + " small gradient-box\">\n        <h3>" + vars.post_count + "</h3>\n        <small>Posts</small>\n      </div>\n    </div>\n\n    <div class=\"one-and-a-half columns\">\n      <div class=\"" + vars.comment_color + " small gradient-box\">\n        <h3>" + vars.comment_count + "</h3>\n        <small>Comments</small>\n      </div>\n    </div>\n\n\n    <div class=\"one-and-a-half columns\">\n      <div class=\"" + vars.score_color + " large gradient-box\">\n        <h3>" + vars.score + "</h3>\n        <small>Total Score</small>\n      </div>\n    </div>\n  </div>\n  <hr/>\n</div>";
};

get_thirds = function(observations) {
  var high_index, len, low_index, mid_index, observation, sorted_observations, step_size, value;
  len = observations.length;
  sorted_observations = (function() {
    var _i, _len, _results;
    _results = [];
    for (_i = 0, _len = observations.length; _i < _len; _i++) {
      observation = observations[_i];
      _results.push(observation);
    }
    return _results;
  })();
  sorted_observations.sort(function(a, b) {
    return a - b;
  });
  if (len === 1) {
    value = sorted_observations[0];
    return {
      low: value,
      mid: value,
      high: value
    };
  } else if (len === 2) {
    return {
      low: sorted_observations[0],
      mid: sorted_observations[0],
      high: sorted_observations[1]
    };
  }
  step_size = Math.floor(len / 3);
  low_index = step_size - 1;
  mid_index = low_index + step_size;
  high_index = mid_index + step_size;
  return {
    low: sorted_observations[low_index],
    mid: sorted_observations[mid_index],
    high: sorted_observations[high_index]
  };
};

get_color = function(compare, ranges, color_map) {
  if (color_map == null) {
    color_map = {
      blue: "blue",
      red: "red",
      green: "green"
    };
  }
  if (isNaN(ranges.mid)) return color_map.blue;
  if (compare >= ranges.high) {
    return color_map.green;
  } else if (compare <= ranges.low) {
    return color_map.red;
  } else {
    return color_map.blue;
  }
};

draw_pageviews_leaderboard = function(container, scores) {
  var author, c, color_map, graph, mapped_scores, pageviews, ranges, score, score_values, _i, _len;
  $("#title").text("Pageviews Leaderboard");
  graph = $("<div id='barchart' style='width:" + (container.innerWidth()) + "px; height: 500px;'></div>");
  container.append(graph);
  mapped_scores = (function() {
    var _results;
    _results = [];
    for (author in scores) {
      pageviews = scores[author];
      _results.push([author, pageviews]);
    }
    return _results;
  })();
  mapped_scores.sort(function(a, b) {
    return b[1] - a[1];
  });
  score_values = (function() {
    var _i, _len, _results;
    _results = [];
    for (_i = 0, _len = mapped_scores.length; _i < _len; _i++) {
      score = mapped_scores[_i];
      _results.push(score[1]);
    }
    return _results;
  })();
  ranges = get_thirds(score_values);
  color_map = {
    blue: "90-#005e7d-#00a5dc",
    green: "90-#617c18-#7c9f1f",
    red: "90-#881313-#ae1919"
  };
  c = new Charts.BarChart('barchart', {
    bar_width: 115,
    bar_margin: 20,
    y_padding: 60,
    rounding: 10,
    x_label_color: "#fff",
    x_label_size: 30,
    y_label_color: "#fff",
    y_label_size: 30
  });
  for (_i = 0, _len = mapped_scores.length; _i < _len; _i++) {
    score = mapped_scores[_i];
    c.add({
      label: score[0],
      value: score[1],
      options: {
        bar_color: get_color(score[1], ranges, color_map)
      }
    });
  }
  return c.draw();
};

draw_leaderboard = function(container, scores) {
  var blog_score, comment_counts, comment_ranges, delay, html, i, is_winner, node, nodes, post_counts, post_ranges, row, score_counts, score_ranges, _i, _j, _len, _len2, _len3, _ref, _results;
  $("#title").text("Blog Post Leaderboard");
  nodes = [];
  html = $("<div>");
  post_counts = [];
  comment_counts = [];
  score_counts = [];
  for (_i = 0, _len = scores.length; _i < _len; _i++) {
    blog_score = scores[_i];
    post_counts.push(blog_score.posts);
    comment_counts.push(blog_score.comments);
    score_counts.push(blog_score.score);
  }
  post_ranges = get_thirds(post_counts);
  comment_ranges = get_thirds(comment_counts);
  score_ranges = get_thirds(score_counts);
  console.log("Posts", post_ranges);
  console.log(post_counts);
  console.log("Comments", comment_ranges);
  console.log(comment_counts);
  console.log("Scores", score_ranges);
  console.log(score_counts);
  for (i = 0, _len2 = scores.length; i < _len2; i++) {
    blog_score = scores[i];
    row = {};
    row.rank = i + 1;
    row.name = blog_score.author;
    row.gravatar = blog_score.gravatar;
    row.post_color = get_color(blog_score.posts, post_ranges);
    row.comment_color = get_color(blog_score.comments, comment_ranges);
    row.score_color = get_color(blog_score.score, score_ranges);
    row.post_count = blog_score.posts;
    row.comment_count = blog_score.comments;
    row.score = blog_score.score;
    is_winner = i === 0;
    node = $(leader_template(row, is_winner));
    nodes.push(node);
    html.append(node);
  }
  container.append(html);
  delay = 0;
  _ref = nodes.slice(0).reverse();
  _results = [];
  for (_j = 0, _len3 = _ref.length; _j < _len3; _j++) {
    node = _ref[_j];
    node.delay(delay).slideDown(200);
    _results.push(delay += 3000);
  }
  return _results;
};

    })
