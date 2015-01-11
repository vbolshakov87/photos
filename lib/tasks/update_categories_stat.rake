#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

# require File.expand_path('../../config/application.rb', __FILE__)
namespace :photo do
  desc "Update the count of all existing categories"
  task update_categories_stat: :environment do
    puts "Start update categories count"

    categories = Category.all
    categories.each do |category|
      count_posts = CategoryPost.where('category_id = ?', category.id).count
      count_photos = CategoryPost.where('category_id = ?', category.id).joins('INNER JOIN posts_photos ON categories_posts.post_id = posts_photos.post_id').count('distinct(posts_photos.photo_id)')
      category[:posts_count] = count_posts
      category[:photos_count] = count_photos
      if category.save
        puts "\t Updated category #{category.title}, post's count=#{category.posts_count}, photo's count=#{category.photos_count}"
      end
    end

    puts "Finish update tags count"
  end
end