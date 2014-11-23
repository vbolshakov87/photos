class CreateTableLinkPostTag < ActiveRecord::Migration
  def change
    execute <<-SQL
      CREATE TABLE `posts_tags` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `post_id` int(11) NOT NULL,
      `tag_id` int(11) NOT NULL,
      PRIMARY KEY (`id`),
      KEY `fk_post` (`post_id`),
      KEY `fk_tag` (`tag_id`),
      CONSTRAINT `posts_tags_ibfk_2` FOREIGN KEY (`tag_id`) REFERENCES `tags` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
      CONSTRAINT `posts_tags_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
    ) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8;
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
    SQL
  end
end
