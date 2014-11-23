class AddSortToImages < ActiveRecord::Migration

  def self.up
    add_column :photos, :sort, :integer, :default => 100
  end

  def self.down
    rename_column :photos, :sort
  end
end
