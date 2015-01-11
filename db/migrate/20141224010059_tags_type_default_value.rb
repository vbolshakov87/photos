class TagsTypeDefaultValue < ActiveRecord::Migration
  def change
    execute <<-SQL
      ALTER TABLE `tags` CHANGE `type` `for` ENUM('post','photo')  CHARACTER SET utf8  COLLATE utf8_general_ci  NULL  DEFAULT 'post';
    SQL
  end
end
