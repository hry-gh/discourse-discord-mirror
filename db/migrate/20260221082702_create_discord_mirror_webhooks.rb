# frozen_string_literal: true

class CreateDiscordMirrorWebhooks < ActiveRecord::Migration[7.0]
  def change
    create_table :discord_mirror_webhooks do |t|
      t.string :key, null: false
      t.string :name, null: false
      t.string :description
      t.integer :channel_id, null: false
      t.timestamps
    end

    add_index :discord_mirror_webhooks, :key, unique: true
  end
end
