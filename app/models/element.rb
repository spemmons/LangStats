class Element < ActiveRecord::Base
  belongs_to :category
  has_many :document_elements
  has_many :interval_elements

  attr_accessible :category_id,:name,:count

  include ElementScopes

  PREDEFINED_ALPHANUMERICS  = 'abcdefghijklmnopqrstuvwxyz0123456789'
  PREDEFINED_PUNCTUATION    = %(`~!@#$\%^&*()-_=+[{]}\|;:'",<.>/?)

  def self.reset_seeds
    existing_count = (previous_alphanumerics = where('category_id = ? and id >= ? and id <= ?',Category::ALPHANUMERIC_ID,1,last_alpha_id = PREDEFINED_ALPHANUMERICS.length)).count
    raise 'problem with alphanumerics' unless existing_count == 0 or existing_count == PREDEFINED_ALPHANUMERICS.length

    existing_count = (previous_punctuation = where('category_id = ? and id >= ? and id <= ?',Category::PUNCTUATION_ID,last_alpha_id + 1,last_alpha_id + PREDEFINED_PUNCTUATION.length)).count
    raise 'problem with punctuation' unless existing_count == 0 or existing_count == PREDEFINED_PUNCTUATION.length

    previous_alphanumerics.delete_all
    previous_punctuation.delete_all

    PREDEFINED_ALPHANUMERICS.split('').each_with_index{|key,index| create_seed(index + 1,Category::ALPHANUMERIC_ID,key)}
    PREDEFINED_PUNCTUATION.split('').each_with_index{|key,index| create_seed(index + last_alpha_id + 1,Category::PUNCTUATION_ID,key)}
  end

  def self.create_seed(id,category_id,name)
    seed = new
    seed.id = id
    seed.category_id = category_id
    seed.name = name
    seed.save!
    seed
  end

  @@element_cache = []

  def self.find_or_create(category_id,name)
    name = name.downcase
    category_cache = @@element_cache[category_id] ||= {}
    category_cache[name] ||= where(category_id: category_id,name: name).first || create!(category_id: category_id,name: name)
  end


  def update_count!
    update_attributes!(count: document_elements.collect(&:count).inject(0){|sum,count| sum + count})
  end

end