# frozen_string_literal: true

# name: discourse-discord-mirror
# about: Mirror Discord messages to Discourse Chat channels
# meta_topic_id: TODO
# version: 0.0.1
# authors: Discourse
# url: TODO
# required_version: 2.7.0

enabled_site_setting :discord_mirror_enabled

module ::DiscordMirror
  PLUGIN_NAME = "discourse-discord-mirror"
end

require_relative "lib/discord_mirror/engine"

after_initialize do
  # Code which should run after Rails has finished booting
end
