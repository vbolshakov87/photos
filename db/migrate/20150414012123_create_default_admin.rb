class CreateDefaultAdmin < ActiveRecord::Migration
  def change
    user = User.new
    user.email = 'admin@localhost.ru'
    user.password = 'admin'
    user.save
  end
end
