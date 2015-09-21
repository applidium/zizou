class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.string :name
      t.integer :attack
      t.integer :midfield
      t.integer :defense

      t.timestamps null: false
    end
  end
end
