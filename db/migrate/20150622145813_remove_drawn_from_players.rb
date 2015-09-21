class RemoveDrawnFromPlayers < ActiveRecord::Migration
  def change
    remove_column :players, :drawn, :integer
  end
end
