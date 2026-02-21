# frozen_string_literal: true

DiscordMirror::Engine.routes.draw do
  post "/hooks/:key" => "webhooks#create"
end

Discourse::Application.routes.draw { mount ::DiscordMirror::Engine, at: "discord-mirror" }
