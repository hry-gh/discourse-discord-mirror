# frozen_string_literal: true

class RemoveChannelIdFromDiscordMirrorWebhooks < ActiveRecord::Migration[7.0]
  def change
    remove_column :discord_mirror_webhooks, :channel_id, :integer
  end
end
