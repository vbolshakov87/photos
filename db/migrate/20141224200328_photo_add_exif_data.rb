class PhotoAddExifData < ActiveRecord::Migration
  def change
    add_column :photos, :exif, :text
  end
end
