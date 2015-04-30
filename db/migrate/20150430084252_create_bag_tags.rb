class CreateBagTags < ActiveRecord::Migration
  def change
    create_table :bag_tags do |t|
      t.string :name, :null => false
      t.integer :tree_depth, :null => false, :default => 0
      t.integer :parent_id

      t.timestamps
    end
    add_index :bag_tags, :parent_id
  end
end
