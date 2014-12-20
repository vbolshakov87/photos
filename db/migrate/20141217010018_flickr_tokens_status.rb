class FlickrTokensStatus < ActiveRecord::Migration
  def change
    add_column :flickr_tokens, :status, "ENUM('accepted', 'cancelled', 'pending')"
  end
end
