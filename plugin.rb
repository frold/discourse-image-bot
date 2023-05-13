# name: discourse-image-bot
# about: Replies a new topic with a images based on values added in the previous post
# version: 0.1
# authors: Frederik Liljefred
# url: https://github.com/frold/discourse-image-bot

after_initialize do
  # If ChartBot user doesn't exist, create it
  if User.find_by_username('ChartBot').nil?
    user = User.create!(
      id: -7, # the desired user ID
      username: 'ChartBot',
      email: 'chartbot@example.com',
      name: 'ChartBot',
      password: SecureRandom.hex(10),
      active: true
    )

    user.activate
  end
end
