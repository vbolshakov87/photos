#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

# require File.expand_path('../../config/application.rb', __FILE__)
namespace :photo do
  desc "Find images in flickr"
  task flickr_get_photos: :environment  do

    puts "Start"

    require 'flickraw'

    FlickRaw.api_key = Rails.application.config.flickr_key
    FlickRaw.shared_secret = Rails.application.config.flickr_secret

    FlickrHelper::flickrLogin(flickr, true)

    list   = flickr.people.getPhotos(:user_id => "me").photo

    list.each do |photo|
      id     = photo.id
      secret = photo.secret
      info = flickr.photos.getInfo :photo_id => id, :secret => secret
      puts info.title           # => "PICT986"
      puts info.dates.taken     # => "2006-07-06 15:16:18"
    end

    puts "Finish"
  end
end