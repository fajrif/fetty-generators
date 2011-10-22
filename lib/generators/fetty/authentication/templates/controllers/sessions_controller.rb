class SessionsController < ApplicationController
  skip_before_filter :authenticate_user!, :except => [:destroy]
  
  def new
    if user_signed_in?
      redirect_to redirect_to_target_or_default_url, :alert => "You already sign-in!"
    end
  end
  
  def create
    @user = User.authenticate!(params[:login], params[:password])
    if @user.is_a? User
      set_session_or_cookies(@user,params[:remember_me])
      redirect_to redirect_to_target_or_default_url, :notice => "Sign in successfully."
    elsif @user == UsersAuthentication::Status::Unexist
      raise "User account not found! please sign up first."
    elsif @user == UsersAuthentication::Status::InvalidPassword
      raise "Invalid username or password."
    elsif @user == UsersAuthentication::Status::Inactivated
      raise "Please activate your account first! check your email."
    end
  rescue Exception => e
    set_session_or_cookies(nil)
    flash.now[:alert] = e.message
    render :action => 'new'
  end
  
  def destroy
    set_session_or_cookies(nil)
    redirect_to root_url, :notice => "Successfully sign out."
  end
  
end
