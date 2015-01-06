class PostPhoto < ActiveRecord::Base
  self.table_name = 'posts_photos'
  belongs_to :posts, class_name: Post
  belongs_to :photos, class_name: Photo
end