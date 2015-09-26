class GamesController < ApplicationController
  respond_to :json

  def index
    @games = Game.all
  end

  def new
    @game = Game.new
  end

  def create
    @game = Game.new(game_params)
    if @game.save
      redirect_to action: :index
    else
      render :new
    end
  end

  private
  def game_params
    params.require(:game).permit(team_player1_attributes: [:player_id, :score], team_player2_attributes: [:player_id, :score])
  end
end
