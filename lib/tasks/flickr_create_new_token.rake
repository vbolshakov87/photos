#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

# require File.expand_path('../../config/application.rb', __FILE__)
namespace :photo do
  desc "Create new flickr token"
  task flickr_create_new_token: :environment do

    puts "Start"

    require 'flickraw'

    FlickRaw.api_key = Rails.application.config.flickr_key
    FlickRaw.shared_secret = Rails.application.config.flickr_secret
    token = flickr.get_request_token
    auth_url = flickr.get_authorize_url(token['oauth_token'], :perms => 'delete')
    puts "Open this url in your process to complete the authication process : #{auth_url}"

    #deactivate previous tokens
    FlickrToken.update_all(
        :status => FlickrToken::STATUS_CANCELED
    )

    #create new token
    FlickrToken.create(
      :oauth_token => token['oauth_token'],
      :oauth_token_secret => token['oauth_token_secret'],
      :auth_url => auth_url,
      :status => FlickrToken::STATUS_PENDING,
    )

    puts "Finish"
  end
end