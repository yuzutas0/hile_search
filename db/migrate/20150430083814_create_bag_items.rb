class CreateBagItems < ActiveRecord::Migration
  def change
    create_table :bag_items do |t|
      t.string :name, :null => false
      t.string :url_dp, :null => false, :unique => true
      t.integer :width, :null => false
      t.integer :height, :null => false
      t.integer :depth
      t.integer :price, :null => false

      t.timestamps
    end
    add_index :bag_items, :url_dp
    add_index :bag_items, :width
    add_index :bag_items, :height
    add_index :bag_items, :depth
    add_index :bag_items, :price
  end
end
