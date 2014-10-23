class AddDateToThePost < ActiveRecord::Migration
  def change
    add_column :posts, :date_from, :datetime
    add_column :posts, :date_to, :datetime
  end
end
