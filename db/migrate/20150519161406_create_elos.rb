class CreateElos < ActiveRecord::Migration
  def change
    create_table :elos do |t|
      t.references :player, index: true, foreign_key: true
      t.float :rating

      t.timestamps null: false
    end
  end
end
