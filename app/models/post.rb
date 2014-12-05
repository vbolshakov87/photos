class Post < ActiveRecord::Base

  has_and_belongs_to_many :tags
  has_and_belongs_to_many :photos
  has_many :post_tag, class_name: PostTag
  has_many :posts_photos, class_name: PostPhoto

  #scope for post
  scope :byName, ->(name) {
    if (name.length > 0)
      where('posts.title LIKE ?', "%#{name}%")
    end

  }

end
