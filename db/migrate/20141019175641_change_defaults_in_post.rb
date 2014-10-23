class ChangeDefaultsInPost < ActiveRecord::Migration
  def change
    execute <<-SQL
      ALTER TABLE `posts` CHANGE `title` `title` VARCHAR(255)  CHARACTER SET utf8  COLLATE utf8_general_ci  NOT NULL  DEFAULT '';
    SQL
  end
end