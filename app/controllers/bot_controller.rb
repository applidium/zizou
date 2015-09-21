require 'slackbot'

class BotController < ApplicationController
  def index
    slackbot = SlackBot.new(params)

    render json: { "text" => slackbot.answer }
  end
end
