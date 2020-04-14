class Document < ApplicationRecord
  def append_content!(chunk)
    self.content += chunk
    save!
  end

  def sync_content!(chunk)
    self.content = chunk
    save!
  end
end
