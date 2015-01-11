class Category < ActiveRecord::Base

  acts_as_tree

  has_many :categories_posts, :class_name => CategoryPost

end
