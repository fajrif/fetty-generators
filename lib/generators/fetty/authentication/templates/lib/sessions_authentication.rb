module SessionsAuthentication
  
  def self.included(receiver)
    receiver.send :helper_method, :current_user, :user_signed_in?
  end
  
  def current_user
    @current_user ||= ( signin_from_session || signin_from_cookies )
  end
  
  def user_signed_in?
    current_user ? true : false
  end
  
  def authenticate_user!
    unless user_signed_in?
      redirect_to new_session_url, :alert => "You must sign in first before accessing this page."
    end
  end
  
  def set_session_or_cookies(user,remember = false)
    if user
      @current_user = user
      if remember
        cookies.permanent.signed[:user_id] = user.id
      else
        session[:user_id] = user.id
      end
    else
      @current_user = nil
      session[:user_id] = nil if session[:user_id]
      cookies.delete :user_id if cookies.signed[:user_id]
      reset_session
    end
  end
  
  def signin_from_session
    User.find(session[:user_id]) if session[:user_id]
  end
  
  def signin_from_cookies
    User.find(cookies.signed[:user_id]) if cookies.signed[:user_id]
  end
  
  def redirect_to_target_or_default_url(default = root_url)
    if request.env["HTTP_REFERER"].blank? || request.env["HTTP_REFERER"] == new_session_url
      default
    else 
      request.env["HTTP_REFERER"]
    end
  end
  
end