require 'twitter'

def session
  config = YAML::load_file('config.yml')

  Twitter::REST::Client.new do |c|
    c.consumer_key = config['twitter_consumer_key']
    c.consumer_secret = config['twitter_consumer_secret']
    c.access_token = config['twitter_access_token']
    c.access_token_secret = config['twitter_access_token_secret']
  end
end

def event_send(tweets)
  tweets = tweets.map do |tweet|
    { name: tweet.user.name, body: tweet.text, avatar: tweet.user.profile_image_url_https }
  end
  send_event('twitter_mentions', comments: tweets)
end

SCHEDULER.every '10m', :first_in => 0 do |job|
  twitter = session
  search_term = URI::encode('#rubyonrails')
  tweets = twitter.search("#{search_term}")

  event_send(tweets) if tweets
end
