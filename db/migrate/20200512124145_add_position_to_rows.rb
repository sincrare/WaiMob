class AddPositionToRows < ActiveRecord::Migration[6.0]
  def change
    add_column :rows, :position, :integer
  end
end
