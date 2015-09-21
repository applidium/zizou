class RemoveWonFromPlayers < ActiveRecord::Migration
  def change
    remove_column :players, :won, :integer
  end
end
