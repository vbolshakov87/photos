class SessionsController < ApplicationController

  skip_before_filter :require_login

  def new
  end

  # login
  def create
    postParams = post_params
    user = User.authenticate(postParams[:email], postParams[:password])
    if user
      SessionsHelper.onLogin(user)
      redirect_to root_url, :notice => 'Logged in!'
    else
      flash.now.alert = 'Invalid email or password'
      render new
    end
  end

  # logout
  def destroy
    SessionsHelper.onLogOut
    redirect_to root_url, :notice => 'Logged out'
  end


  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def post_params
    postParams = params
  end

end
