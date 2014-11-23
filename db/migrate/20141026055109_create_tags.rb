class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :title
      t.integer :count

      t.timestamps null: false
    end
  end
end
