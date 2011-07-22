class UsersController < ApplicationController
  skip_before_filter :authenticate_user!, :except => [:edit, :update]

  def show
    @user = current_user
  end
  
  def new
    @user = User.new
  end

  def create
    @user = User.new(:username => params[:username], :email => params[:email], :password => params[:password], :password_confirmation => params[:password_confirmation])
    if @user.save
      redirect_to new_session_url, :notice => "Activation link has been sent to your email. Please activate first!"
    else
      raise "Unable to create user account."
    end
  rescue Exception => e
    flash.now[:alert] = e.message
    render :action => 'new'
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update_attributes(:username => params[:username], :email => params[:email], :password => params[:password], :password_confirmation => params[:password_confirmation])
      redirect_to root_url, :notice => "Your profile has been updated."
    else
      raise "Unable to update your profile."
    end
  rescue Exception => e
    flash.now[:alert] = e.message
    render :action => 'edit'
  end
  
  def activate
    user = User.activate!(params[:id],params[:token])
    if user.is_a? User
      set_session_or_cookies(user)
      redirect_to root_url, :notice => "Your account has been activated!"
    elsif user == UsersAuthentication::Status::Unexist
      raise "Invalid user account and activation code"
    elsif user == UsersAuthentication::Status::Activated
      raise "You already activated this account."
    end
  rescue Exception => e
    set_session_or_cookies(nil)
    redirect_to new_session_url, :alert => e.message
  end
  
end
