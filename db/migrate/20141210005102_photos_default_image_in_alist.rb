class PhotosDefaultImageInAlist < ActiveRecord::Migration
  def change
    add_column :photos, :main, :integer, :limit => 1
  end
end
