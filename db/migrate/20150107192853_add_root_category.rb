class AddRootCategory < ActiveRecord::Migration
  def change
    cat = Category.new
    cat.title = 'root'
    cat.save
  end
end
