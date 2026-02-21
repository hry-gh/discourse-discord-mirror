# frozen_string_literal: true

module ::DiscordMirror
  class Webhook < ActiveRecord::Base
    self.table_name = "discord_mirror_webhooks"

    validates :key, presence: true, uniqueness: true
    validates :name, presence: true

    before_validation :generate_key, on: :create

    private

    def generate_key
      self.key ||= SecureRandom.hex(16)
    end
  end
end
