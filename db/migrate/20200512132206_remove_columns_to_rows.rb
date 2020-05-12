class RemoveColumnsToRows < ActiveRecord::Migration[6.0]
  def change
    remove_column :rows, :previous_row_id
    remove_column :rows, :next_row_id
  end
end
