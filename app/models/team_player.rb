class TeamPlayer < ActiveRecord::Base
  belongs_to :team
  belongs_to :player

  after_destroy :undo

  validates :score, presence: true, :numericality => { :greater_than_or_equal_to => 0 }

  def undo
    player.elos.order(:created_at).last.destroy
    player.destroy if player.elos.count <= 1
  end
end
