# frozen_string_literal: true

module ::DiscordMirror
  class WebhooksController < ::ApplicationController
    requires_plugin PLUGIN_NAME

    skip_before_action :verify_authenticity_token
    skip_before_action :redirect_to_login_if_required
    skip_before_action :check_xhr

    def create
      webhook = Webhook.find_by(key: params[:key])

      unless webhook
        return render json: { success: false, error: "Invalid webhook key" }, status: :unauthorized
      end

      discord_user_params = params.require(:discord_user).permit(:id, :username, :avatar_url)
      message_params = params.require(:message).permit(:content, :discord_message_id)

      if discord_user_params[:id].blank? || discord_user_params[:username].blank?
        return(
          render json: { success: false, error: "Missing discord_user id or username" },
                 status: :bad_request
        )
      end

      if message_params[:content].blank?
        return(
          render json: { success: false, error: "Missing message content" }, status: :bad_request
        )
      end

      channel = Chat::Channel.find_by(id: webhook.channel_id)
      unless channel
        return render json: { success: false, error: "Chat channel not found" }, status: :not_found
      end

      user =
        ShadowUser.find_or_create(
          discord_user_id: discord_user_params[:id],
          username: discord_user_params[:username],
          avatar_url: discord_user_params[:avatar_url],
        )

      message =
        Chat::CreateMessage.call(
          guardian: Guardian.new(user),
          params: {
            chat_channel_id: channel.id,
            message: message_params[:content],
          },
        )

      if message.success?
        render json: { success: true, discourse_message_id: message.message_instance.id }
      else
        render json: { success: false, error: message.failure }, status: :unprocessable_entity
      end
    end
  end
end
