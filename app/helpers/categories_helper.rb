module CategoriesHelper



  def self.category_tree(skip_itself = false, id_to_skip = 0)
    categories = Category.find(1).subtree.arrange(:order => :title)
    categoriesArray = []
    level = 1
    categories.map do |category, sub_categories|
      categoriesArray.push(
        {
          :id => category.id,
          :title => category.title,
          :level => level
        }
      )

      sub_categories.each do |sub_category|
        categoriesArray = self.add_level_to_category_arr(categoriesArray, sub_category[0], level+1, skip_itself, id_to_skip)
      end

      return categoriesArray
    end
  end


  def self.add_level_to_category_arr(categoriesArray, category, level, skip_itself, id_to_skip)

    if (skip_itself === false || !(id_to_skip.to_i == category.id.to_i))

      categoriesArray.push(
        {
          :id => category.id,
          :title => category.title,
          :level => level
        }
      )

      if (category.has_children?)
        category.children.each do |sub_category|
          categoriesArray = self.add_level_to_category_arr(categoriesArray, sub_category, level+1, skip_itself, id_to_skip)
        end
      end

    end

    return categoriesArray
  end

end