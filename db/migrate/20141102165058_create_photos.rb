class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
      t.string :title
      t.string :original_name
      t.integer :width
      t.integer :height

      t.timestamps null: false
    end
  end
end
