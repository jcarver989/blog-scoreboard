var add_if_missing, draw_leaderboard, get_color, get_median, leader_template;
$(document).ready(function() {
  var one_minute;
  $.getJSON("/scores").then(draw_leaderboard);
  one_minute = 60000;
  return setInterval(function() {
    return $.getJSON("/scores").then(draw_leaderboard);
  }, one_minute);
});
leader_template = function(vars, is_winner) {
  return "<div style=\"display: none;\">\n  <div class=\"row " + (is_winner ? "winner" : "") + "\">\n    <div class=\"three-quarters column\">\n      <h2 class=\"rank\">" + vars.rank + ".</h2>\n    </div>\n\n    <div class=\"one-and-a-half columns\">\n      <img class=\"gravatar\" src=\"" + vars.gravatar + "\" />\n    </div>\n\n    <div class=\"three columns\">\n      <h2>" + vars.name + "</h2>\n    </div>\n\n    <div class=\"one-and-a-half columns\">\n      <div class=\"" + vars.post_color + " small gradient-box\">\n        <h3>" + vars.post_count + "</h3>\n        <small>Posts</small>\n      </div>\n    </div>\n\n    <div class=\"one-and-a-half columns\">\n      <div class=\"" + vars.comment_color + " small gradient-box\">\n        <h3>" + vars.comment_count + "</h3>\n        <small>Comments</small>\n      </div>\n    </div>\n\n\n    <div class=\"one-and-a-half columns\">\n      <div class=\"" + vars.score_color + " large gradient-box\">\n        <h3>" + vars.score + "</h3>\n        <small>Total Score</small>\n      </div>\n    </div>\n  </div>\n  <hr/>\n</div>";
};
get_median = function(sorted_observations) {
  var index, len, mid1, mid2;
  len = sorted_observations.length;
  if (len === 1) {
    return sorted_observations[0];
  }
  index = Math.floor(len / 2);
  if (len % 2 === 0) {
    mid1 = sorted_observations[index - 1];
    mid2 = sorted_observations[index];
    return (mid1 + mid2) / 2;
  } else {
    return sorted_observations[index];
  }
};
get_color = function(num_items, median) {
  if (median === 0 || isNaN(median)) {
    return "blue";
  }
  if (num_items > median) {
    return "green";
  } else {
    return "blue";
  }
};
add_if_missing = function(array, item) {
  if (array.indexOf(item) === -1) {
    return array.push(item);
  }
};
draw_leaderboard = function(scores) {
  var blog_score, comment_counts, comment_median, container, delay, html, i, is_winner, node, nodes, post_counts, post_median, row, score_counts, score_median, _i, _j, _len, _len2, _len3, _ref, _results;
  container = $("#leaderBoard");
  container.html("");
  nodes = [];
  html = $("<div>");
  post_counts = [];
  comment_counts = [];
  score_counts = [];
  for (_i = 0, _len = scores.length; _i < _len; _i++) {
    blog_score = scores[_i];
    add_if_missing(post_counts, blog_score.posts);
    add_if_missing(comment_counts, blog_score.comments);
    add_if_missing(score_counts, blog_score.score);
  }
  post_median = get_median(post_counts);
  comment_median = get_median(comment_counts);
  score_median = get_median(score_counts);
  for (i = 0, _len2 = scores.length; i < _len2; i++) {
    blog_score = scores[i];
    row = {};
    row.rank = i + 1;
    row.name = blog_score.author;
    row.gravatar = blog_score.gravatar;
    row.post_color = get_color(blog_score.posts, post_median);
    row.comment_color = get_color(blog_score.comments, comment_median);
    row.score_color = get_color(blog_score.score, score_median);
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