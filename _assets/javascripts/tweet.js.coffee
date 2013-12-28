$feed = $('#twitter-feed')

if $feed.length
  $list = $('<ul class="tweet_list slides">')
  $slider = $('<div class="flexslider">').append($list)
  $feed.append($slider)

  host = if location.hostname.match(/\.dev$/) then 'r3-api.dev' else 'api.r3missions.org'
  $.ajax
    url: "http://#{host}/twitter"
    dataType: 'jsonp'
    cache: true
    success: (data) ->
      $list.empty()
      for tweet in data.tweets
        $li = $('<li class="slide">').html(formatTweet(tweet))
        $list.append($li)

formatTweet = (tweet) ->
  date = parseDate(tweet.created_at)
  """
    <span class="tweet_text">#{linkifyEntities(tweet)}</span> –
    @<a href="https://twitter.com/#{tweet.username}" target="_blank">#{tweet.username}</a>,
    <span class="tweet_time"><a href="https://twitter.com/#{tweet.username}/status/#{tweet.id}" title="view tweet on twitter" target="_blank">#{relativeTime(date)}</a></span>
  """

parseDate = (dateStr) ->
  # The non-search twitter APIs return inconsistently-formatted dates, which Date.parse
  # cannot handle in IE. We therefore perform the following transformation:
  # "Wed Apr 29 08:53:31 +0000 2009" => "Wed, Apr 29 2009 08:53:31 +0000"
  Date.parse(dateStr.replace(/^([a-z]{3})( [a-z]{3} \d\d?)(.*)( \d{4})$/i, '$1,$2$4$3'))

relativeTime = (date, relativeTo=new Date()) ->
  delta = parseInt((relativeTo.getTime() - date) / 1000, 10)
  if delta < 1
    "just now"
  else if delta < 60
    "#{delta} seconds ago"
  else if delta < 120
    "about a minute ago"
  else if delta < (45*60)
    "about #{parseInt(delta / 60, 10)} minutes ago"
  else if delta < (2*60*60)
    "about an hour ago"
  else if delta < (24*60*60)
    "about #{parseInt(delta / 3600, 10)} hours ago"
  else if delta < (48*60*60)
    "about a day ago"
  else
    "about #{parseInt(delta / 86400, 10)} days ago"

escapeHTML = (text) ->
  return $('<div/>').text(text).html()

linkifyEntities = (tweet) ->
  return escapeHTML(tweet.text) unless tweet.entities

  # This is very naive, should find a better way to parse this
  indexMap = {}

  addToIndex = (indices, fn) ->
    [start, end] = indices
    indexMap[start] = [end, fn(tweet.text.substring(start, end))]

  for entry in tweet.entities.urls
    addToIndex entry.indices, (text) ->
      "<a href=\"#{escapeHTML(entry.expanded_url)}\" target=\"_blank\">#{escapeHTML(entry.display_url)}</a>"

  for entry in tweet.entities.hashtags
    addToIndex entry.indices, (text) ->
      "<a href=\"http://twitter.com/search?q=#{escape("#"+entry.text)}\" target=\"_blank\">#{escapeHTML(text)}</a>"

  for entry in tweet.entities.user_mentions
    addToIndex entry.indices, (text) ->
      "<a title=\"#{escapeHTML(entry.name)}\" href=\"http://twitter.com/#{escapeHTML(entry.screen_name)}\" target=\"_blank\">#{escapeHTML(text)}</a>"

  for entry in tweet.entities.media
    addToIndex entry.indices, (text) ->
      "<a href=\"#{escapeHTML(entry.expanded_url)}\" target=\"_blank\">#{escapeHTML(entry.display_url)}</a>"

  result = ""
  starts = (parseInt(x) for x in Object.keys(indexMap)).sort((a,b) -> a-b)
  lastPos = 0

  for pos in starts
    [end, replacement] = indexMap[pos]
    result += escapeHTML(tweet.text.substring(lastPos, pos)) if pos > lastPos
    result += replacement
    lastPos = end

  result += escapeHTML(tweet.text.substring(lastPos)) if lastPos < tweet.text.length

  result
