class Player < ActiveRecord::Base
  attr_accessor :slack_username

  has_many :team_players
  has_many :elos, dependent: :destroy

  validates :username, uniqueness: true

  scope :player, -> { where(type: nil) }

  def pro?
    elos.any? { |elo| elo.rating >= Elo::PRO_RATING }
  end

  def starter?
    elos.size < Elo::STARTER_BOUNDRY
  end

  def member_name(members)
    member = members.detect{ |m| m["id"] == self.username }
    member.present? ? member["name"] : "unknown"
  end

  def games_played(from = nil)
    _elos = elos.all
    _elos = _elos.where("created_at >= ?", from) if from.present?

    _elos.count - (from.present? ? 0 : 1)
  end

  def won(from = nil)
    Game.find_by_player(self, from).select { |g| g.winner.player == self rescue false }.length
  end

  def lost(from = nil)
    Game.find_by_player(self, from).select { |g| g.loser.player == self rescue false }.length
  end

  def drawn(from = nil)
    Game.find_by_player(self, from).select { |g| g.drawn? }.length
  end

  def teams_statistics
    team_players = TeamPlayer.where(player: self).group_by(&:team)
    all_tp = team_players.values.flatten.length
    teams = Hash[ team_players.map { |team, tp| [team.name, ((tp.length.to_f / all_tp.to_f)*100).round(2)] } ]

    teams.sort_by { |team, score| score }
  end

  def largest_victory
    games = Game.find_by_player(self)

    largest_score = 0
    largest_score_game = nil
    games.each do |game|
      diff = 0
      if game.team_player1.player == self
        diff = game.team_player1.score - game.team_player2.score
      else
        diff = game.team_player2.score - game.team_player1.score
      end

      if diff > largest_score
        largest_score = diff
        largest_score_game = game
      end
    end

    largest_score_game
  end

  def opponent_statistics
    response = {}
    Player.player.each do |player|
      rate = win_rate_against(player)
      response[player.username] = rate unless rate.nil?
    end
    response.sort_by { |username, score| score }
  end

  def win_rate_against(opponent)
    games = Game.find_with_players(self, opponent)

    return nil if games.empty?

    won = games.select { |game| game.winner.present? and game.winner.player == self }.length
    ((won.to_f / games.length.to_f).round(2) * 100)
  end

  def k_factor
    if pro?
      return Elo::K_FACTOR_PRO
    elsif starter?
      return Elo::K_FACTOR_STARTER
    else
      return Elo::K_FACTOR_OTHER
    end
  end

  def rating(from = nil)
    return Elo::INITIAL_RATING if elos.empty?

    base = from.present? ? rating_at(from) : 0
    elos.last.rating  - base
  end

  def rating_at(date)
    elos.where("created_at <= ?", date).last.rating rescue Elo::INITIAL_RATING
  end

  def compute_new_rating(result, opponent_rating)
    new_rating = rating + (k_factor.to_f * (result.to_f - Elo.expected(rating, opponent_rating))).to_i
    Elo.create(player: self, rating: new_rating)
  end

  # returns the ratio (wins - loses) / #games against another player
  def compare(player)
    # fetch all matches between both players
    games = Game.find_with_players(self, player)
    total = 0

    games.each do |game|
      next if game.drawn?
      total += 1 if game.winner.player == self
      total -= 1 if game.winner.player == player
    end

    (total.to_f / games.length.to_f)
  end

  def goals_scored(from = nil)
    team_players = TeamPlayer.where(player: self)
    team_players = team_players.where("created_at >= ?", from) if from.present?

    team_players.inject(0) { |sum, tp| sum + tp.score }
  end

  def goals_conceded(from = nil)
    games = Game.find_by_player(self, from)

    games.inject(0) { |sum, game| sum + (game.team_player1.player == self ? game.team_player2.score : game.team_player1.score) }
  end

  # initialize a new player with the initial elo rating
  after_create do |player|
    Elo.create(player: player, rating: Elo::INITIAL_RATING)
  end
end
