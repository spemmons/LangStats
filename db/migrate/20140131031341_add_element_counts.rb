class AddElementCounts < ActiveRecord::Migration
  def change
    change_table :elements do |t|
      t.integer :count
    end
  end
end
