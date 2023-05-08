# name: discourse-image-bot
# about: Replies a new topic with a images based on values added in the previous post
# version: 0.1
# authors: Frederik Liljefred
# url: https://github.com/frold/discourse-image-bot

gem 'mini_magick'
require 'mini_magick'

enabled_site_setting :chartbot_enabled

after_initialize do
  module ::DiscourseChartbot
    class Engine < ::Rails::Engine
      engine_name "discourse_chartbot"
      isolate_namespace DiscourseChartbot
    end
  end

  class ::DiscourseChartbot::ChartbotUser < ::User
    def self.chartbot
      @chartbot ||= DiscourseChartbot::ChartbotUser.find_or_initialize_by(username: "ChartBot") do |u|
        u.id = "-09"
        u.name = "ChartBot"
        u.email = "chartbot@discourse.com"
        u.password = SecureRandom.hex
        u.active = true
        u.approved = true
        u.trust_level = TrustLevel[1]
        u.save!
      end
    end
  end 
 
  DiscourseEvent.on(:post_created) do |post|
    if SiteSetting.chartbot_enabled && post.user != DiscourseChartbot::ChartbotUser.chartbot
      if post.raw.include?("@ChartBot")
        variables = post.raw.match(/@ChartBot\s([^\s]+)\s([^\s]+)/)
        if variables.present?
          ticker = variables[1]
          interval = variables[2]
          url = "https://charts2.finviz.com/chart.ashx?t=#{ticker}&ty=c&ta=0&p=#{interval}&s=l"
          file = Tempfile.new(["chart-", ".png"])
          MiniMagick::Tool::Convert.new do |convert|
            convert.size "800x600"
            convert << url
            convert << file.path
          end
          post.reply_to_post!(
            "Here's the chart for #{ticker} on a #{interval} interval:",
            user: DiscourseChartbot::ChartbotUser.chartbot,
            skip_validations: true,
            auto_track: false,
            uploaded_files: [Upload.create_from(file.path, file, "image/png")]
          )
        end
      end
    end
  end
