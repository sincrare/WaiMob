class AddTokentToDocuments < ActiveRecord::Migration[6.0]
  def change
    add_column :documents, :token, :string
  end
end
