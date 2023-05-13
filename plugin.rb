# name: discourse-image-bot
# about: Replies a new topic with a images based on values added in the previous post
# version: 0.1
# authors: Frederik Liljefred
# url: https://github.com/frold/discourse-image-bot

    bot = User.find_by(id: -07)

    # Handles creation of bot if it doesn't exist
    if !bot
        response_username = "ChartBot"
        response_name = "Vores Finviz Bot"
    
        # bot created
        bot = User.new
        bot.id = -07
        bot.name = response_name
        bot.username = response_username
        bot.email = "responseBot@me.com"
        bot.username_lower = response_username.downcase
        bot.password = SecureRandom.hex
        bot.active = true
        bot.approved = true
        bot.trust_level = TrustLevel[1]
    end

on(:post_created) do |post, params|
  if post.raw.match?(/@ChartBot\s+(\w+)\s+(\w+)/i)
    tickerid = $1
    tiden = $2
    link = "https://charts2.finviz.com/chart.ashx?t=#{tickerid}&ty=c&ta=0&p=#{tiden}&s=l"
    post.topic.posts.create!(
      user: User.find_by(username: 'ChartBot'),
      raw: "Here is a link to the Finviz chart: #{link}"
    )
  end
end
