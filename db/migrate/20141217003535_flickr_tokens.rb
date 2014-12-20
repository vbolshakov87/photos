class FlickrTokens < ActiveRecord::Migration
  def change
    create_table :flickr_tokens do |t|
      t.string :oauth_token
      t.string :oauth_token_secret
      t.string :auth_url
      t.string :verify_code
      t.string :access_token
      t.string :access_secret

      t.timestamps null: false
    end
  end
end
