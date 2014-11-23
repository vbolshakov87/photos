class AddDefaultToPostDates < ActiveRecord::Migration
  def change
    execute <<-SQL
      ALTER TABLE `photos`
      CHANGE `created_at` `created_at` DATETIME  NULL,
      CHANGE `updated_at` `updated_at` DATETIME  NULL;
    SQL
  end
end
