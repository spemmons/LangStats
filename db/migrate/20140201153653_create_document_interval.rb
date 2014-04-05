class CreateDocumentInterval < ActiveRecord::Migration
  def change
    create_table :intervals do |t|
      t.integer :document_id
      t.integer :interval_number
      t.integer :interval_size
      t.integer :line_count
      t.integer :word_count
      t.integer :char_count
      t.integer :alphanumeric_count
      t.integer :punctuation_count
    end

    add_index :intervals,[:document_id,:interval_number,:interval_size],name: 'intervals_all_ids'

    create_table :interval_elements do |t|
      t.integer :interval_id
      t.integer :category_id
      t.integer :element_id
      t.integer :count,default: 0
    end

    add_index :interval_elements,[:element_id]
    add_index :interval_elements,[:category_id,:element_id]
    add_index :interval_elements,[:interval_id,:category_id,:element_id],name: 'interval_elements_all_ids'
    add_index :interval_elements,[:interval_id,:element_id]
  end
end
