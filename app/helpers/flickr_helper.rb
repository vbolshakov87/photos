module FlickrHelper

  def self.flickrLogin(flickr, showLoginMessage = false)
    # get last active token
    activeToken = FlickrToken.activeToken.last
    if (!activeToken.present?)
      raise 'active token does not exist'
    end

    if (activeToken.access_token.length == 0 || activeToken.access_secret.length == 0)
      raise 'active token is not set in DB level'
    end

    flickr.access_token = activeToken.access_token
    flickr.access_secret = activeToken.access_secret

    begin
      login = flickr.test.login
    rescue FlickRaw::FailedResponse => e
      raise "Authentication failed : #{e.msg}"
    end

    if (showLoginMessage === true)
      puts "You are now authenticated as #{login.username}"
    end

    return flickr
  end

end