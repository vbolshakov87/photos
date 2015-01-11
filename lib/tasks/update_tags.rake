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
      countTagsCriteria = tag.for == Tag::TYPE_POST ? PostTag : PhotoTag
      countTags = countTagsCriteria.where("tag_id = ?", tag.id).count
      tag[:count] = countTags
      if tag.save
        puts "\t Updated tag #{tag.title}, count=#{tag.count}"
      end
    end

    puts "Finish update tags count"
  end
end