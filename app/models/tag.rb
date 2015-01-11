class Tag < ActiveRecord::Base

  TYPE_POST = 'post'
  TYPE_PHOTO = 'photo'

  has_and_belongs_to_many :posts
  has_many :post_tag, class_name: PostTag

  has_and_belongs_to_many :photos
  has_many :photo_tag, class_name: PhotoTag


  #scope for post
  scope :searchByTag, ->(q) {
    q = q.to_s.strip
    if (q.length > 0)
      where(["title like ?", "%#{q}%"])
    end
  }

  scope :from_post, -> { where('tags.for = ?', Tag::TYPE_POST) }
  scope :from_photo, -> { where('tags.for = ?', Tag::TYPE_PHOTO) }

end
