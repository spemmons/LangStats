class Document < ActiveRecord::Base
  belongs_to :author
  belongs_to :genre

  has_many :elements,dependent: :delete_all,class_name: DocumentElement.to_s
  include ElementSet

  has_many :intervals,dependent: :destroy

  attr_accessible :author,:genre,:title,:source,:first_line,:last_line,:url,:filename

end