module SessionsHelper

  def self.onLogin(user)
    session[:user] = user
  end

  def self.onLogOut
    session[:user] = nil
  end
end
