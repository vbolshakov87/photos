class TagAddType < ActiveRecord::Migration
  def change
    add_column :tags, :type, "ENUM('post', 'photo')"
  end
end
