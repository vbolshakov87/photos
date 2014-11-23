class PhotosRemoveColumns < ActiveRecord::Migration
  def change
    execute <<-SQL
    ALTER TABLE `photos`
      DROP `original_name`,
      DROP `width`,
      DROP `height`;
    SQL
  end
end
