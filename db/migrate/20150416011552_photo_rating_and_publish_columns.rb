class PhotoRatingAndPublishColumns < ActiveRecord::Migration
  def change
    add_column :photos, :rating, :integer, :limit => 1, :default => 0
    add_column :photos, :publish_on_facebook, :integer, :limit => 1, :default => 0
    add_column :photos, :publish_on_twitter, :integer, :limit => 1, :default => 0
    add_column :photos, :publish_on_flickr, :integer, :limit => 1, :default => 1
    add_column :photos, :publish_on_500px, :integer, :limit => 1, :default => 0
  end
end
