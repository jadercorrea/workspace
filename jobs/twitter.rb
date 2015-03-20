require 'twitter'

config = YAML::load_file('config.yml')

twitter = Twitter::REST::Client.new do |c|
  c.consumer_key = config['twitter_consumer_key']
  c.consumer_secret = config['twitter_consumer_secret']
  c.access_token = config['twitter_access_token']
  c.access_token_secret = config['twitter_access_token_secret']
end

search_term = URI::encode('#rubyonrails')

SCHEDULER.every '10m', :first_in => 0 do |job|
  begin
    tweets = twitter.search("#{search_term}")

    if tweets
      tweets = tweets.map do |tweet|
        { name: tweet.user.name, body: tweet.text, avatar: tweet.user.profile_image_url_https }
      end
      send_event('twitter_mentions', comments: tweets)
    end
  rescue Twitter::Error
    puts "\e[33mFor the twitter widget to work, you need to put in your twitter API keys in the jobs/twitter.rb file.\e[0m"
  end
end
