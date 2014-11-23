class LinkPhotosPosts < ActiveRecord::Migration
  def change
    execute <<-SQL
      CREATE TABLE `posts_photos` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `post_id` int(11) NOT NULL,
      `photo_id` int(11) NOT NULL,
      PRIMARY KEY (`id`),
      KEY `fk_post` (`post_id`),
      KEY `fk_photo` (`photo_id`),
      CONSTRAINT `posts_photos_ibfk_2` FOREIGN KEY (`photo_id`) REFERENCES `photos` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
      CONSTRAINT `posts_photos_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
    SQL
  end
end
