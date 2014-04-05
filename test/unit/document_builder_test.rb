require 'test_helper'

class DocumentBuilderTest < ActiveSupport::TestCase

  def setup
    Category.reset_seeds
    Element.reset_seeds
  end

  test 'Huck Finn' do
    #dr = DocumentReader.new(source: 'datafiles/huckfinn.txt',start_after: 'Produced by David Widger',end_before: 'End of the Project Gutenberg EBook')
    #dr.process
  end

  test 'Wuthering Heights' do
    #dr = DocumentReader.new(source: 'datafiles/wutheringheights.txt',start_after: 'ccx074@pglaf.org',end_before: '***END OF THE PROJECT GUTENBERG EBOOK')
    dr = DocumentBuilder.new(source: 'http://www.gutenberg.org/cache/epub/768/pg768.txt',start_after: 'ccx074@pglaf.org',end_before: '***END OF THE PROJECT GUTENBERG EBOOK')
    dr.process
  end
end
