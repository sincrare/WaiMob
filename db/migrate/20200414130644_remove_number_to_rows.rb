class RemoveNumberToRows < ActiveRecord::Migration[6.0]
  def change
    remove_column :rows, :number
  end
end
