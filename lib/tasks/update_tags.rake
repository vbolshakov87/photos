#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

# require File.expand_path('../../config/application.rb', __FILE__)
namespace :photo do
  desc "Update the count of all existing tags"
  task update_tags_count: :environment do
    puts "Start update tags count"

    tags = Tag.all
    tags.each do |tag|
      count_tags_criteria = tag.for == Tag::TYPE_POST ? PostTag : PhotoTag
      count_tags = count_tags_criteria.where("tag_id = ?", tag.id).count
      tag[:count] = count_tags
      if tag.save
        puts "\t Updated tag #{tag.title}, count=#{tag.count}"
      end
    end

    puts "Finish update tags count"
  end
end