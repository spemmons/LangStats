module ElementSet

  extend ActiveSupport::Concern

  def alphanumeric_entropy
    @alphanumeric_entropy ||= Category.scope_entropy(elements.alphanumerics)
  end

  def punctuation_entropy
    @punctuation_entropy ||= Category.scope_entropy(elements.punctuation)
  end

  def word_entropy
    @word_entropy ||= Category.scope_entropy(elements.words)
  end

end