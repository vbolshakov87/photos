#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

# require File.expand_path('../../config/application.rb', __FILE__)
namespace :photo do
  desc "Set exif data to the database for the images where exif is empty"
  task set_exif: :environment do
    puts "Start"

    photos = Photo.where('exif is null').all
    photos.each do |photo|

      path = Rails.root + photo.image.path(:original)

     if Rails.application.config.exif_provider === 'exiftool'
        exifInfo =  ExifInfoExiftool.new(path)
      else
        exifInfo =  ExifInfoImagick.new(path)
      end

      exifData = exifInfo.get_exif

      photo.exif = ActiveSupport::JSON.encode(exifData)
      # if rating >= 4, the picture is automatically set to be published in social networks
      if exifData[:rating].present? && exifData[:rating] >= Photo::RATING_MIN_500PX
        photo.publish_on_500px = Photo::STATUS_TO_PUBLISH
        photo.publish_on_facebook = Photo::STATUS_TO_PUBLISH
        photo.publish_on_twitter = Photo::STATUS_TO_PUBLISH
        photo.rating = exifData[:rating]
      end
      if (photo.save)
        puts "\t Photo id=#{photo.id} exif is saved"
      end
    end
    puts "Finish"
  end
end