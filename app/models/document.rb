class Document < ApplicationRecord
  has_many :rows, dependent: :destroy

  def append_content!(chunk)
    self.content += chunk
    save!
  end

  def sync_content!(chunk)
    self.content = chunk
    save!
  end
end
