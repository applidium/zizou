class Elo < ActiveRecord::Base
	STARTER_BOUNDRY = 30
	INITIAL_RATING = 1500
	PRO_RATING = 1700
	K_FACTOR_STARTER = 25
	K_FACTOR_PRO = 10
	K_FACTOR_OTHER = 15

  belongs_to :player

  def self.expected(own_rating, opponent_rating)
    1.0 / ( 1.0 + ( 10.0 ** ((opponent_rating - own_rating) / 400.0) ) )
  end
end
