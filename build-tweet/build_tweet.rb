require './build_tweet_functions.rb'

def postTweet(title, url)
  Twitter.configure do |config|
    config.consumer_key = CONFIG['consumer_key']
    config.consumer_secret = CONFIG['consumer_secret']
    config.oauth_token = CONFIG['oauth_token']
    config.oauth_token_secret = CONFIG['oauth_token_secret']
  end

  #puts CONFIG['base_url'] + url
  tweet = "A new post: " + title + " " + url 
  Twitter.update(tweet)
end

postTweet(ARGV[0])
