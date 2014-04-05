class IntervalElement < ActiveRecord::Base
  belongs_to :interval
  belongs_to :category
  belongs_to :element

  attr_accessible :category_id,:element_id

  include ElementScopes
end