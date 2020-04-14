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

  def ordered_rows
    first_row = self.rows.find_by(previous_row: nil)
    count = 0
    rows = [first_row]
    row = first_row
    while row = row.next_row
      rows << row
      count += 1
      if count > 1000
        raise 'over rows'
      end
    end
    rows
  end
end
