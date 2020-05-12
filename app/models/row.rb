class Row < ApplicationRecord
  belongs_to :document
  belongs_to :next_row, class_name: 'Row', optional: true
  belongs_to :previous_row, class_name: 'Row', optional: true
end
