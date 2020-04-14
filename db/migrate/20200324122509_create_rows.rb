class CreateRows < ActiveRecord::Migration[6.0]
  def change
    create_table :rows do |t|
      t.integer :number, null: false
      t.text :content, null: false, default: ''
      t.references :document, null: false, foreign_key: true, index: false

      t.timestamps
    end

    add_index :rows, [:document_id, :number], unique: true
  end
end
