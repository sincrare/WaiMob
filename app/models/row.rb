class Row < ApplicationRecord
  belongs_to :document
  acts_as_list scope: :document
end
