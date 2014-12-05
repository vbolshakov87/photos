class Post < ActiveRecord::Base

  has_and_belongs_to_many :tags
  has_and_belongs_to_many :photos

  #scope for post
  scope :byName, ->(name) {
    if (name.length > 0)
      where('posts.title LIKE ?', "%#{name}%")
    end

  }

end
