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
      redirect_to new_user_session_url, :notice => "Activation link has been sent to your email. Please activate first!"
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
    redirect_to new_user_session_url, :alert => e.message
  end
  
  def new_forgot_password
  end

  def forgot_password
    if user = User.first(:conditions => { :username => params[:login] }) || User.first(:conditions => { :email => params[:login] })
      if user.activated?
        user.send_forgot_password_instructions!
        flash.now[:notice] = "We've sent an email to #{user.email} containing instructions on how to reset your password."
        render :action => 'new_forgot_password'
      else
        raise "Account has never been activated, please activate your account first before resetting your password."
      end
    else
      raise "Could not find any account with that username / email address."
    end
  rescue Exception => e
    flash.now[:alert] = e.message
    render :action => 'new_forgot_password'
  end

  def new_reset_password
    unless @user = User.first(:conditions => {:id => params[:id], :token => params[:token]})
      redirect_to new_user_forgot_password_url, :alert => "Unable to find an account, Please follow the URL from your email / send the new reset instructions!"
    end
  end
  
  def reset_password
    if @user = User.first(:conditions => {:id => params[:id], :token => params[:token]})
      if @user.reset_password(params[:password],params[:password_confirmation]) == UsersAuthentication::Status::Valid
        redirect_to new_user_session_url, :notice => "Your password was successfully updated, Please login using your new password!"
      else
        raise "Unable to reset your password!"
      end
    else
      raise "Unable to find an account, Please follow the URL from your email / send the new reset instructions!"
    end
  rescue Exception => e
    flash.now[:alert] = e.message
    render :action => 'new_reset_password'
  end
  
end
