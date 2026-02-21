# frozen_string_literal: true

# name: discourse-discord-mirror
# about: Mirror Discord messages to Discourse Chat channels
# meta_topic_id: TODO
# version: 0.0.1
# authors: Discourse
# url: TODO
# required_version: 2.7.0

enabled_site_setting :discord_mirror_enabled

register_asset "stylesheets/common/discord-mirror.scss"

module ::DiscordMirror
  PLUGIN_NAME = "discourse-discord-mirror"
end

require_relative "lib/discord_mirror/engine"

after_initialize do
  # Exclude shadow users (negative IDs) from user search
  register_modifier(:user_search_ids) { |ids| ids.select { |id| id > 0 } }

  # Block profile access for shadow users
  reloadable_patch do |plugin|
    Guardian.prepend(
      Module.new do
        def can_see_profile?(user)
          return false if user&.bot? && !is_staff?
          super
        end
      end,
    )
  end
end
