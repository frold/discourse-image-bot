# name: discourse-image-bot
# about: Replies a new topic with a images based on values added in the previous post
# version: 0.1
# authors: Frederik Liljefred
# url: https://github.com/frold/discourse-image-bot

PLUGIN_NAME ||= "chartbot".freeze

after_initialize do
  User.create!(
    id: '-09',
    username: 'ChartBot',
    name: 'Vores ChartBot',
    email: 'chartbot@example.com',
    password: SecureRandom.hex(10),
    active: true,
    approved: true,
    trust_level: 'TrustLevel[1]'
  )
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
