class Game < ActiveRecord::Base
  belongs_to :team_player1, dependent: :destroy, class_name: "TeamPlayer"
  belongs_to :team_player2, dependent: :destroy, class_name: "TeamPlayer"

  validates :team_player1, presence: :true
  validates :team_player2, presence: :true

  accepts_nested_attributes_for :team_player1
  accepts_nested_attributes_for :team_player2

  def self.find_by_player(player, from = nil)
    team_players = TeamPlayer.where(player: player)
    team_players = team_players.where("created_at >= ?", from) if from.present?
    team_players = team_players.pluck(:id)

    # fetch all matches with this player
    Game.where("team_player1_id in (?) or team_player2_id in (?)", team_players, team_players)
  end

  def self.find_with_players(player1, player2)
    team_player1 = TeamPlayer.where(player: player1).pluck(:id)
    team_player2 = TeamPlayer.where(player: player2).pluck(:id)

    Game.where(team_player1: team_player1 + team_player2, team_player2: team_player1 + team_player2)
  end

  def winner
    # a <=> b == 1 if a > b, -1 if a < b, 0 if a == b
    case team_player1.score <=> team_player2.score
    when -1
      return team_player2
    when 1
      return team_player1
    end
  end

  def loser
    team_player = self.winner
    return nil if team_player.blank?

    team_player == self.team_player1 ? self.team_player2 : self.team_player1
  end

  def drawn?
    team_player1.score == team_player2.score
  end

  before_create do |game|
    result_player1 = logistic(goal_difference + team_difference)
    result_player2 = 1 - result_player1

    player1 = team_player1.player
    player2 = team_player2.player

    rating_player1 = player1.rating
    rating_player2 = player2.rating

    # As player1's rating will be updated first, use cached ratings instead of
    # player1.rating directly
    player1.compute_new_rating(result_player1, rating_player2)
    player2.compute_new_rating(result_player2, rating_player1)
  end

  def team_difference
    return (team_player2.team.team_factor - team_player1.team.team_factor) * 10 rescue 0
  end

  def goal_difference
    return team_player1.score - team_player2.score
  end

  def logistic(x)
    1.0 / (1.0 + Math.exp(-x))
  end
end
