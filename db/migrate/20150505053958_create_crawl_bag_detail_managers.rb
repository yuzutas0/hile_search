class CreateCrawlBagDetailManagers < ActiveRecord::Migration
  def change
    create_table :crawl_bag_detail_managers do |t|
      t.text :url
      t.integer :bag_tag_id
      t.boolean :done_flag, :null => false, :default => false
      t.boolean :error_flag, :null => false, :default => false

      t.timestamps
    end
    add_index :crawl_bag_detail_managers, :bag_tag_id
  end
end
