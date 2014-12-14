class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  http_basic_authenticate_with name: "admin", password: "admin"

  before_filter :require_login

  helper_method :current_user

  private

  def current_user
    @current_user ||= session[:user] if session[:user].present?
  end

  def require_login
    unless current_user
      redirect_to log_in_path
    end
  end
end
