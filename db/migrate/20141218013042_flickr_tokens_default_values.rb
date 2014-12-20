class FlickrTokensDefaultValues < ActiveRecord::Migration
  def change
    execute <<-SQL
      ALTER TABLE `flickr_tokens`
      CHANGE `status` `status` ENUM('accepted','cancelled','pending')  CHARACTER SET utf8  COLLATE utf8_general_ci  NULL  DEFAULT 'pending',
      CHANGE `oauth_token` `oauth_token` VARCHAR(255)  CHARACTER SET utf8  COLLATE utf8_general_ci  NOT NULL  DEFAULT '',
      CHANGE `oauth_token_secret` `oauth_token_secret` VARCHAR(255)  CHARACTER SET utf8  COLLATE utf8_general_ci  NOT NULL  DEFAULT '',
      CHANGE `auth_url` `auth_url` VARCHAR(255)  CHARACTER SET utf8  COLLATE utf8_general_ci  NOT NULL  DEFAULT '';
    SQL
  end
end
