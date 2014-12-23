class PhotoRemoveMain < ActiveRecord::Migration
  def change
    remove_column :photos, :main
  end
end
