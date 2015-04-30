class CreateDeviceItems < ActiveRecord::Migration
  def change
    create_table :device_items do |t|
      t.string :name, :null => false
      t.integer :width, :null => false
      t.integer :height, :null => false
      t.integer :depth
      t.integer :device_brand_id, :null => false

      t.timestamps
    end
    add_index :device_items, :device_brand_id
    add_index :device_items, :width
    add_index :device_items, :height
    add_index :device_items, :depth
  end
end
