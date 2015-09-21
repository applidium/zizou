class AddHistoryToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :won, :integer, default: 0
    add_column :players, :drawn, :integer, default: 0
    add_column :players, :lost, :integer, default: 0
  end
end
