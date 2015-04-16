class CategoriesPosts < ActiveRecord::Migration

  def self.up
    execute <<-SQL
      CREATE TABLE `categories_posts` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `post_id` int(11) NOT NULL,
      `category_id` int(11) NOT NULL,
      PRIMARY KEY (`id`),
      KEY `fk_post` (`post_id`),
      KEY `fk_category` (`category_id`),
      CONSTRAINT `categories_posts_ibfk_2` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
      CONSTRAINT `categories_posts_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
    SQL
  end

  def self.down
    execute <<-SQL
      DROP TABLE `categories_posts`;
    SQL
  end

end
