class RemoveLostFromPlayers < ActiveRecord::Migration
  def change
    remove_column :players, :lost, :integer
  end
end
