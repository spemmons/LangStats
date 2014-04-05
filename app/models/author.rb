class Author < ActiveRecord::Base
  has_many :documents

  attr_accessible :name
end