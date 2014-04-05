module ElementScopes

  extend ActiveSupport::Concern

  included do
    scope :alphanumerics, where(category_id: Category::ALPHANUMERIC_ID)
    scope :punctuation,   where(category_id: Category::PUNCTUATION_ID)
    scope :words,         where(category_id: Category::WORD_ID)
    scope :ngrams2,       where(category_id: Category::NGRAM2_ID)
    scope :ngrams3,       where(category_id: Category::NGRAM3_ID)
  end

end