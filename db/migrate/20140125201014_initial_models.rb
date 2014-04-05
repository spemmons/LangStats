class InitialModels < ActiveRecord::Migration
  def change

    create_table :authors do |t|
      t.string :name
    end

    create_table :genres do |t|
      t.string :name
    end

    create_table :documents do |t|
      t.integer :author_id
      t.integer :genre_id
      t.string  :url
      t.string  :filename
      t.string  :title
      t.integer :first_line
      t.integer :last_line
      t.integer :line_count
      t.integer :word_count
      t.integer :char_count
      t.integer :alphanumeric_count
      t.integer :punctuation_count
    end

    create_table :categories do |t|
      t.string :name
    end

    create_table :elements do |t|
      t.integer :category_id
      t.string  :name
    end

    create_table :document_elements do |t|
      t.integer :document_id
      t.integer :category_id
      t.integer :element_id
      t.integer :count,default: 0
    end

    add_index :document_elements,[:element_id]
    add_index :document_elements,[:category_id,:element_id]
    add_index :document_elements,[:document_id,:category_id,:element_id],name: 'document_elements_all_ids'
    add_index :document_elements,[:document_id,:element_id]

  end
end
