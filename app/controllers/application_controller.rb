class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def current_user 
    @current_user ||= User.find_by(id: session["user_id"])
  end
  helper_method :current_user

  def require_login
    unless logged_in?
      flash[:error] = "You must be logged in. Log In."
      redirect_to login_path
    end
  end

  def logged_in?
    !!current_user
  end
end
