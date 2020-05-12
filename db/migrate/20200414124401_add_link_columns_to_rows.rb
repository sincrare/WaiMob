class AddLinkColumnsToRows < ActiveRecord::Migration[6.0]
  def change
    add_reference :rows, :previous_row, foreign_key: { to_table: :rows }
    add_reference :rows, :next_row, foreign_key: { to_table: :rows }
  end
end
