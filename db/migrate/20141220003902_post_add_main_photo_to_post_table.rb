class PostAddMainPhotoToPostTable < ActiveRecord::Migration
  def change
    execute <<-SQL
      ALTER TABLE `posts` ADD `main_photo` INT(11)  NULL  AFTER `date_to`,
      ADD FOREIGN KEY (`main_photo`) REFERENCES `photos` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;
    SQL
  end
end
