class Category < ActiveRecord::Base

  ALPHANUMERIC_ID = 1
  PUNCTUATION_ID  = 2
  WORD_ID         = 3
  NGRAM2_ID       = 4
  NGRAM3_ID       = 5

  has_many :elements
  has_many :document_elements
  has_many :interval_elements

  def self.reset_seeds
    delete_all
    create_seed(ALPHANUMERIC_ID,'Alphanumeric')
    create_seed(PUNCTUATION_ID, 'Punctuation')
    create_seed(WORD_ID,        'Word')
    create_seed(NGRAM2_ID,      'NGram(2)')
    create_seed(NGRAM3_ID,      'NGram(3)')
  end

  def self.create_seed(id,name)
    seed = new
    seed.id = id
    seed.name = name
    seed.save!
    seed
  end

  def self.reset_entropy
    @@alphanumeric_entropy,@@punctuation_entropy,@@word_entropy = nil,nil,nil
  end

  reset_entropy

  def self.alphanumeric_entropy
    @@alphanumeric_entropy ||= scope_entropy(Element.alphanumerics)
  end

  def self.punctuation_entropy
    @@punctuation_entropy ||= scope_entropy(Element.punctuation)
  end

  def self.word_entropy
    @@word_entropy ||= scope_entropy(Element.words)
  end

  def self.scope_entropy(scope)
    return 0.0 if (counts = scope.collect(&:count)).empty?

    total = counts.inject(0.0){|sum,count| sum + count}
    chances = counts.collect{|count| count / total}
    chances.inject(0.0){|sum,chance| sum - Math.log2(chance) * chance}
  end

end