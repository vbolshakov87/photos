class Tag < ActiveRecord::Base
  has_and_belongs_to_many :posts
  has_many :post_tag, class_name: PostTag
end
