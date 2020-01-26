class AddNameAndDescriptionToRoom < ActiveRecord::Migration[6.0]
  def change
    add_column :rooms, :name, :string, null:false, default: ""
    add_column :rooms, :description, :string, null:false, default: ""
  end
end
