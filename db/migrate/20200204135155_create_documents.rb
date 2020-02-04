class CreateDocuments < ActiveRecord::Migration[6.0]
  def change
    create_table :documents do |t|
      t.string :title, null: false, default: ''
      t.text :content, null: false, default: ''

      t.timestamps
    end
  end
end
