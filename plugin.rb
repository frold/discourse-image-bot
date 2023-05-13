# name: discourse-image-bot
# about: Replies a new topic with a images based on values added in the previous post
# version: 0.1
# authors: Frederik Liljefred
# url: https://github.com/frold/discourse-image-bot

after_initialize do
  require_dependency 'post'

  module ::TickeridLinkPlugin
    class Engine < ::Rails::Engine
      engine_name 'tickerid_link_plugin'
      isolate_namespace TickeridLinkPlugin
    end
  end

  class ::Post
    after_save :add_tickerid_link

    def add_tickerid_link
      tickerid = ''
      tiden = ''
      mentioned_users.each do |user|
        if user.username == 'frold'
          tickerid, tiden = extract_tickerid_and_tiden_from_mention(user)
          break
        end
      end

      if tickerid.present? && tiden.present?
        link = "https://charts2.finviz.com/chart.ashx?t=#{tickerid}&ty=c&ta=0&p=#{tiden}&s=l"
        self.raw += "\n\n#{link}"
        self.save
      end
    end

    private

    def extract_tickerid_and_tiden_from_mention(user)
      mention_text = user.mention.to_s.strip
      _, tickerid, tiden = mention_text.match(/@frold\s+(\S+)\s+(\S+)/).to_a
      [tickerid, tiden]
    end
  end
end
