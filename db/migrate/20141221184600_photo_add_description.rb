class PhotoAddDescription < ActiveRecord::Migration
  def change
    add_column :photos, :content, :text
  end
end
