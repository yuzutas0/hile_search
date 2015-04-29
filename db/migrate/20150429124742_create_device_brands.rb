class CreateDeviceBrands < ActiveRecord::Migration
  def change
    create_table :device_brands do |t|
      t.string :name, :null => false
      t.integer :tree_depth, :null => false, :default => 0
      t.boolean :leaf_flag, :null => false, :default => true
      t.integer :parent_id

      t.timestamps
    end
    add_index :device_brands, :tree_depth
    add_index :device_brands, :parent_id
  end
end
