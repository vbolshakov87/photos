class PhotoTagsTable < ActiveRecord::Migration
  def change
    execute <<-SQL
      CREATE TABLE `photos_tags` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `photo_id` int(11) NOT NULL,
      `tag_id` int(11) NOT NULL,
      PRIMARY KEY (`id`),
      KEY `fk_photo` (`photo_id`),
      KEY `fk_tag` (`tag_id`),
      CONSTRAINT `photos_tags_ibfk_2` FOREIGN KEY (`tag_id`) REFERENCES `tags` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
      CONSTRAINT `photos_tags_ibfk_1` FOREIGN KEY (`photo_id`) REFERENCES `photos` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
    SQL
  end
end