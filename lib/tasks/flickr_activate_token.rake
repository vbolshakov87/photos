#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

# require File.expand_path('../../config/application.rb', __FILE__)
namespace :photo do
  desc "Activate flickr token"
  task :flickr_activate_token, [:code] => [:environment] do |t, args|

    puts "Start"

    if (args.code.present?)

      require 'flickraw'

      FlickRaw.api_key = Rails.application.config.flickr_key
      FlickRaw.shared_secret = Rails.application.config.flickr_secret

      #get last pending tokens
      pendingToken = FlickrToken.pendingToken.last

      verify = args.code.strip

      begin
        flickr.get_access_token(pendingToken.oauth_token, pendingToken.oauth_token_secret, verify)
        login = flickr.test.login

        pendingToken.verify_code = verify
        pendingToken.access_token = flickr.access_token
        pendingToken.access_secret = flickr.access_secret
        pendingToken.status = FlickrToken::STATUS_ACCEPTED
        pendingToken.save

        puts "You are now authenticated as #{login.username} with token #{flickr.access_token} and secret #{flickr.access_secret}"

      rescue FlickRaw::FailedResponse => e
        puts "Authentication failed : #{e.msg}"
      end
    else
      puts 'code is not set, auth cannot be executed'
    end

    puts "Finish"
  end
end