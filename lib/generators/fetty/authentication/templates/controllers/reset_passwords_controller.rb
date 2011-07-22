class ResetPasswordsController < ApplicationController
  skip_before_filter :authenticate_user!
  
  def new
  end
  
  def create
    if user = User.first(:conditions => { :username => params[:login] }) || User.first(:conditions => { :email => params[:login] })
      if user.activated?
        user.send_forgot_password_instructions!
        flash.now[:notice] = "We've sent an email to #{user.email} containing instructions on how to reset your password."
        render :action => 'new'
      else
        raise "Account has never been activated, please activate your account first before resetting your password."
      end
    else
      raise "Could not find any account with that username / email address."
    end
  rescue Exception => e
    flash.now[:alert] = e.message
    render :action => 'new'
  end
  
  def edit
    unless @user = User.first(:conditions => { :id => params[:id], :token => params[:token] })
      redirect_to new_reset_password_url, :alert => "Unable to find an account, Please follow the URL from your email / send the new reset instructions!"
    end
  end
  
  def update
    if @user = User.first(:conditions => { :id => params[:id], :token => params[:token] })
      if @user.reset_password(params[:password],params[:password_confirmation]) == UsersAuthentication::Status::Valid
        redirect_to new_session_url, :notice => "Your password was successfully updated, Please login using your new password!"
      else
        raise "Unable to reset your password!"
      end
    else
      raise "Unable to find an account, Please follow the URL from your email / send the new reset instructions!"
    end
  rescue Exception => e
    flash.now[:alert] = e.message
    render :action => 'edit'
  end
  
end
