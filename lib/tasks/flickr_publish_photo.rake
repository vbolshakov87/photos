#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

# require File.expand_path('../../config/application.rb', __FILE__)
namespace :photo do
  desc "Publish images and sets in flickr"
  task flickr_publish_photo: :environment  do

    require 'flickraw'

    FlickRaw.api_key = Rails.application.config.flickr_key
    FlickRaw.shared_secret = Rails.application.config.flickr_secret

    FlickrHelper::flickrLogin(flickr, true)

    PHOTO_PATH='/Users/vladimir/Documents/projects/my/photo2/public/system/photos/images/000/000/002/medium/20140103-20140103-DSC_0889.jpg'
    flickrId = flickr.upload_photo PHOTO_PATH, :title => "Title 1", :description => "This is the description 1"
    puts "Finish"
  end
end