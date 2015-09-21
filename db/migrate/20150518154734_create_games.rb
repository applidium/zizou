class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.references :team_player1, references: :team_player, index: true
      t.references :team_player2, references: :team_player, index: true

      t.timestamps null: false
    end
  end
end
