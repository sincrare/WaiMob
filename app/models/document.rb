class Document < ApplicationRecord
  has_many :rows, -> { order(position: :asc) }, dependent: :destroy
  has_secure_token

  def append_content!(chunk)
    self.content += chunk
    save!
  end

  def sync_content!(chunk)
    self.content = chunk
    save!
  end
end
