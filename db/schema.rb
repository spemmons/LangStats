# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140219143123) do

  create_table "authors", :force => true do |t|
    t.string "name"
  end

  create_table "categories", :force => true do |t|
    t.string "name"
  end

  create_table "document_elements", :force => true do |t|
    t.integer "document_id"
    t.integer "category_id"
    t.integer "element_id"
    t.integer "count",       :default => 0
  end

  add_index "document_elements", ["category_id", "element_id"], :name => "index_document_elements_on_category_id_and_element_id"
  add_index "document_elements", ["document_id", "category_id", "element_id"], :name => "document_elements_all_ids"
  add_index "document_elements", ["document_id", "element_id"], :name => "index_document_elements_on_document_id_and_element_id"
  add_index "document_elements", ["element_id"], :name => "index_document_elements_on_element_id"

  create_table "documents", :force => true do |t|
    t.integer "author_id"
    t.integer "genre_id"
    t.string  "url"
    t.string  "filename"
    t.string  "title"
    t.integer "first_line"
    t.integer "last_line"
    t.integer "line_count"
    t.integer "word_count"
    t.integer "char_count"
    t.integer "alphanumeric_count"
    t.integer "punctuation_count"
    t.string  "locale"
  end

  create_table "elements", :force => true do |t|
    t.integer "category_id"
    t.string  "name"
    t.integer "count"
  end

  create_table "genres", :force => true do |t|
    t.string "name"
  end

  create_table "interval_elements", :force => true do |t|
    t.integer "interval_id"
    t.integer "category_id"
    t.integer "element_id"
    t.integer "count",       :default => 0
  end

  add_index "interval_elements", ["category_id", "element_id"], :name => "index_interval_elements_on_category_id_and_element_id"
  add_index "interval_elements", ["element_id"], :name => "index_interval_elements_on_element_id"
  add_index "interval_elements", ["interval_id", "category_id", "element_id"], :name => "interval_elements_all_ids"
  add_index "interval_elements", ["interval_id", "element_id"], :name => "index_interval_elements_on_interval_id_and_element_id"

  create_table "intervals", :force => true do |t|
    t.integer "document_id"
    t.integer "interval_number"
    t.integer "interval_size"
    t.integer "line_count"
    t.integer "word_count"
    t.integer "char_count"
    t.integer "alphanumeric_count"
    t.integer "punctuation_count"
  end

  add_index "intervals", ["document_id", "interval_number", "interval_size"], :name => "intervals_all_ids"

end
