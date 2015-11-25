require 'slack'

class PlayersController < ApplicationController
  respond_to :json

  def index
    @players = Player.all.sort_by(&:rating).reverse
  end

  def create
    @player = Player.new(player_params)
    if @player.save
      redirect_to action: :index
    else
      render :new
    end
  end

  def show
    @player = Player.find(params[:id])
  end

  def new
    @player = Player.new
  end

  private
  def player_params
    params.require(:player).permit(:username)
  end
end
