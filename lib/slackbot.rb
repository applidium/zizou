require 'slack'
require 'ribery'
require 'terminal-table'
require 'net/http'

class SlackBot
  def initialize(params)
    @user_id = params["user_id"]
    @text = params["text"] || ""
    @trigger_word = params["trigger_word"] || "fifa"
    @slack_token = params["token"]
  end

  def answer
    return "Nice try, monkey." if @slack_token != ENV["SLACK_WEBHOOK_TOKEN"]

    data = @text.split

    begin
      return self.send("hear_#{data[1]}", *data[2..-1])
    rescue Exception => e
      puts e
      return help
    end
  end

  def help
    answer = "List of commands (optional parameters are between [brackets]):\n"

    # hearers are methods starting with 'hear_'
    hearers = self.private_methods.select { |m| m.to_s.start_with? "hear_" }

    hearers.each do |hearer|
      parameters = self.method(hearer).parameters.map { |p| p.first == :opt ? "[#{p.second}]" : p.second }
      answer += "\t#{@trigger_word} #{hearer.to_s[5..-1]} " + parameters.join(" ") + "\n"
    end

    answer
  end

  private

  # takes an user_id and formats it in order to let Slack highlight the user
  def format_username(user_id)
    "<@#{user_id}>"
  end

  # takes an username (with Slack's format) and extracts the user_id
  def extract_user_id(username)
    username[2..-2]
  end

  def create_game_with_players(player1, player2, team1, team2, score1, score2)
    team_player1 = TeamPlayer.create(player: player1, team: team1, score: score1.to_i)
    team_player2 = TeamPlayer.create(player: player2, team: team2, score: score2.to_i)

    Game.create(team_player1: team_player1, team_player2: team_player2)
  end

  def ranking_for_scope(scope, n_weeks)
    n_weeks = n_weeks.to_i
    from = Date.today.beginning_of_week - (n_weeks - 1).week if n_weeks > 0

    ranking = scope.map { |player| { :rating => player.rating(from), :player => player} }
    ranking.sort_by! { |pr| -pr[:rating] }

    members = Slack.members
    return "Error: Couldn't fetch members list" if members.blank?

    rows = []

    ranking.each_with_index do |pr, index|
      goals_for = pr[:player].goals_scored(from)
      goals_against = pr[:player].goals_conceded(from)
      goal_difference = goals_for - goals_against

      name = pr[:player].member_name(members)

      rows << ["#{index+1}", name, "#{pr[:player].games_played(from)}", "#{pr[:player].won(from)}", "#{pr[:player].drawn(from)}", "#{pr[:player].lost(from)}", "#{goals_for}", "#{goals_against}", "#{goal_difference}", "#{pr[:rating].to_i}"]
    end

    table = Terminal::Table.new :title => "Ligapplidium: League Table", :headings => ["Rang", "Joueur", "J.", "G.", "N.", "P.", "BP", "BC", "Diff.", "Rating"], :rows => rows
    table.align_column(8, :right) # right align the diff column content
    table.align_column(9, :center) # center align the rating column content

    "```#{table}```"
  end

  def r_for_scope(scope, n_weeks)
    n_weeks = n_weeks.to_i
    from = Date.today.beginning_of_week - (n_weeks - 1).week if n_weeks > 0

    ranking = scope.map { |player| { :rating => player.rating(from), :player => player} }
    ranking.sort_by! { |pr| -pr[:rating] }

    members = Slack.members
    return "Error: Couldn't fetch members list" if members.blank?

    rows = ranking.map.with_index do |pr, index|
      name = pr[:player].member_name(members)
      "#{index+1}. #{name} (#{pr[:rating].to_i})"
    end

    rows.join("\n")
  end

  # all hearers

  def hear_ranking(n_weeks = 0)
    ranking_for_scope(Player.player, n_weeks)
  end

  def hear_r(n_weeks = 0)
    r_for_scope(Player.player, n_weeks)
  end

  def hear_match(player1, team1, score1, player2, team2, score2)
    _player1 = Player.find_or_create_by(username: extract_user_id(player1))
    _player2 = Player.find_or_create_by(username: extract_user_id(player2))

    _team1, _team2 = Team.find_by_name(team1), Team.find_by_name(team2)

    return "Unknown team: #{team1}" if _team1.nil?
    return "Unknown team: #{team2}" if _team2.nil?

    game = create_game_with_players(_player1, _player2, _team1, _team2, score1, score2)

    answer = "Successfully created match: (#{player1}, #{team1}, #{score1}) - (#{player2}, #{team2}, #{score2})"

    return answer
  end

  def hear_teams
    teams = Team.order(:name)
    teams.map { |team| "#{team.name}\tA: #{team.attack}\tM: #{team.midfield}\tD: #{team.defense}" }.join("\n")
  end

  def hear_addteam(name, attack, midfield, defense)
    Team.create_or_update(name: name, attack: attack, midfield: midfield, defense: defense)

    "#{name}(#{attack}, #{midfield}, #{defense}) created."
  end

  def hear_challenge(player, time = "")
    other_user_id = extract_user_id(player)
    challenge_created = false

    if time.length > 0
      date = DateTime.parse(time) rescue nil
      return "That time seems off, I could not create a challenge." if date.nil?

      now = DateTime.now
      if (date.hour > now.hour) || (date.hour == now.hour && date.min > now.min)
        Challenge.find_or_create_by(player1_id: @user_id, player2_id: other_user_id, date: date)
        challenge_created = true
      end
    end

    player1 = Player.find_by(username: @user_id)
    player2 = Player.find_by(username: other_user_id)

    score = player1.compare(player2)

    answer = "#{format_username(@user_id)} wants to play against #{format_username(other_user_id)}"
    answer += " at #{time}" if challenge_created

    answer
  end

  def hear_challenges
    challenges = Challenge.where("date >= ?", DateTime.now).order(:date)
    answer = "Challenges:\n"
    answer += challenges.map { |challenge| "#{format_username(challenge.player1_id)} vs #{format_username(challenge.player2_id)} at #{challenge.date.strftime("%H:%M")}" }.join("\n")
    answer
  end

  def hear_stats(player)
    player_id = extract_user_id(player)
    player = Player.find_by(username: player_id)

    return "Could not find any player with that username. John Doe is that you?" if player.nil?

    answer = "Awesome details about #{format_username(player_id)}'s fifa career :\n"
    answer << "Most played teams : - "
    answer << player.teams_statistics.last(3).map { |team, score| "#{team}: #{score}%" }.join(" - ")
    answer << "\n"
    answer << "Toughest opponents (% of victories) : "
    answer << player.opponent_statistics.take(3).map { |opponent, score| "#{format_username(opponent)} : #{score}%" }.join(" - ")
    answer << "\n"
    answer << "Weakest opponents (% of victories) : "
    answer << player.opponent_statistics.last(3).reverse.map { |opponent, score| "#{format_username(opponent)} : #{score}%" }.join(" - ")
    answer << "\n Overall stats : \n"

    percentage = lambda { |x| (100.0 * x / player.games_played.to_f).round(2) }
    win_rate = percentage.call(player.won.to_f)
    loss_rate = percentage.call(player.lost.to_f)
    draw_rate = percentage.call(player.drawn.to_f)

    answer << "Victories : #{win_rate}%, Losses : #{loss_rate}%, Draws : #{draw_rate}%\n"
    largest_victory = player.largest_victory
    if !largest_victory.nil?
      answer << "Biggest victory ever: #{format_username(largest_victory.team_player1.player.username)}"
      answer << " #{largest_victory.team_player1.team.name} #{largest_victory.team_player1.score}"
      answer << " - #{largest_victory.team_player2.score} #{largest_victory.team_player2.team.name}"
      answer << " #{format_username(largest_victory.team_player2.player.username)}"
    end
    answer
  end

  def hear_undo
    minutes = 3

    game = Game.last

    return "No match was created within the last #{minutes} minutes" if game.blank? or game.created_at < DateTime.now - minutes.minute

    game.destroy

    "Last match registered was destroyed. Stats have been updated."
  end

  def hear_ribery
    Ribery::QUOTES.sample
  end
end
