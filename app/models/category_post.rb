class CategoryPost < ActiveRecord::Base
  self.table_name = 'categories_posts'

  belongs_to :posts, class_name: Post
  belongs_to :categories, class_name: Category
end
