require './build_tweet_functions.rb'

f = File.read(CONFIG['git_base']+"/"+"newPost.txt")

toTweet = []
f.each_line { |line|
    toTweet.push line
}
#puts toTweet[0]
#puts toTweet[1]
postTweet(toTweet[0], toTweet[1])
