# frozen_string_literal: true

module ::DiscordMirror
  class ShadowUser
    PLUGIN_STORE_KEY_PREFIX = "discord_user_"
    SHADOW_ID_START = -3000
    SHADOW_ID_END = -1_000_000_000

    def self.find_or_create(discord_user_id:, username:, avatar_url:)
      new(discord_user_id:, username:, avatar_url:).find_or_create
    end

    def initialize(discord_user_id:, username:, avatar_url:)
      @discord_user_id = discord_user_id
      @username = username
      @avatar_url = avatar_url
    end

    def find_or_create
      discourse_user_id = PluginStore.get(DiscordMirror::PLUGIN_NAME, store_key)

      if discourse_user_id
        user = User.find_by(id: discourse_user_id)
        if user
          update_avatar_if_changed(user)
          return user
        end
      end

      create_shadow_user
    end

    private

    def store_key
      "#{PLUGIN_STORE_KEY_PREFIX}#{@discord_user_id}"
    end

    def create_shadow_user
      shadow_id = allocate_shadow_user_id
      raise "No available shadow user IDs" unless shadow_id

      username = generate_unique_username

      user =
        User.new(
          id: shadow_id,
          username: username,
          name: @username,
          email: "discord_#{@discord_user_id}@shadow.invalid",
          password: SecureRandom.hex(32),
          active: true,
          approved: true,
          trust_level: TrustLevel[0],
        )

      user.save!(validate: false)

      PluginStore.set(DiscordMirror::PLUGIN_NAME, store_key, user.id)

      update_avatar(user) if @avatar_url.present?

      user
    end

    def allocate_shadow_user_id
      key = "next_shadow_user_id"
      next_id = PluginStore.get(DiscordMirror::PLUGIN_NAME, key)&.to_i || SHADOW_ID_START

      raise "Shadow user ID limit reached" if next_id < SHADOW_ID_END

      PluginStore.set(DiscordMirror::PLUGIN_NAME, key, next_id - 1)
      next_id
    end

    def generate_unique_username
      "d_#{@discord_user_id}"
    end

    def update_avatar_if_changed(user)
      return if @avatar_url.blank?

      stored_avatar_url =
        PluginStore.get(DiscordMirror::PLUGIN_NAME, "avatar_url_#{@discord_user_id}")
      return if stored_avatar_url == @avatar_url

      update_avatar(user)
    end

    def update_avatar(user)
      return if @avatar_url.blank?

      begin
        UserAvatar.import_url_for_user(@avatar_url, user)
        PluginStore.set(DiscordMirror::PLUGIN_NAME, "avatar_url_#{@discord_user_id}", @avatar_url)
      rescue StandardError => e
        Rails.logger.warn("DiscordMirror: Failed to import avatar for user #{user.id}: #{e.message}")
      end
    end
  end
end
