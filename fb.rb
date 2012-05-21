require 'koala'

APP_ID = "278805638854140"
APP_SECRET = "e9c6224fd66411a8d8ea3a9cc1ac10f8"

TOKEN = 'AAAD9kn8QtfwBAKn3cM0G2CEw3m36g2snPo8bmw4ZCxTm1istx3JEH7Thw4OsBTAJ8coKcXHm7kdGm81UU6TBFnbIoxcgbS1i9EIn2sgZDZD'

FB_URI = 'https://www.facebook.com/dialog/oauth?client_id=278805638854140&redirect_uri=http:%2F%2flocalhost%2Ffb&scope=manage_pages&response_type=token'

@oauth = Koala::Facebook::OAuth.new(APP_ID, APP_SECRET, 'http://localhost/fb/')

code = @oauth.url_for_oauth_code(:permissions => "publish_stream")
puts @oauth.get_access_token_info(code)
