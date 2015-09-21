class AddTypeToPlayer < ActiveRecord::Migration
  def change
    add_column :players, :type, :string
  end
end
