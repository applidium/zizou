class Team < ActiveRecord::Base
  has_many :team_players

  validates :attack, :numericality => { :greater_than => 0, :less_than_or_equal_to => 100 }
  validates :midfield, :numericality => { :greater_than => 0, :less_than_or_equal_to => 100 }
  validates :defense, :numericality => { :greater_than => 0, :less_than_or_equal_to => 100 }

  before_create do |team|
  	team.total = team.attack + team.midfield + team.defense
    team.name = team.name.upcase
  end

  def team_factor
    return self.total / Team.average(:total)
  end

  def self.find_by_name(name)
    Team.find_by(name: name.upcase)
  end

  def self.create_or_update(options = {})
    team = Team.find_by(name: options[:name] || "")

    if team.blank?
      team = Team.create(options)
    else
      team.update(options)
    end

    team
  end
end
