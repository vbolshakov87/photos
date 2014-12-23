class PostAddGeo < ActiveRecord::Migration
  def change
    add_column :posts, :geo_latitude, :float
    add_column :posts, :geo_longitude, :float
    add_column :photos, :geo_latitude, :float
    add_column :photos, :geo_longitude, :float
  end
end
