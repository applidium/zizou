class ChangePlayerIdTypesForChallenges < ActiveRecord::Migration
  def change
    change_column :challenges, :player1_id,  :string
    change_column :challenges, :player2_id,  :string
  end
end
