class AddTotalToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :total, :integer
  end
end
