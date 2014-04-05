class AddLocale < ActiveRecord::Migration
  def change
    add_column :documents,:locale,:string
  end
end
