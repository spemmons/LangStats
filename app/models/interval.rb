class Interval < ActiveRecord::Base
  belongs_to :document

  has_many :elements,dependent: :delete_all,class_name: IntervalElement.to_s
  include ElementSet

  attr_accessible :interval_number,:interval_size

end