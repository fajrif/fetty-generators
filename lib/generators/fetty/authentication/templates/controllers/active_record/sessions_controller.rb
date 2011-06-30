class SessionsController < ApplicationController
  skip_before_filter :authenticate_user!, :except => [:destroy]
  
  def new
  end

  def create
    user = User.authenticate(params[:login], params[:password])
    if user
      if user.activated?
        cookies[:user_id] = { :value => user.id, :expires => 1.days.from_now }
        redirect_to (request.env["HTTP_REFERER"].blank? ? root_url : request.env["HTTP_REFERER"]), :notice => "Logged in successfully."
      else
        raise "Please activate your account first! check your email."
      end
    else
      raise "Invalid login or password."
    end
  rescue Exception => e
    flash.now[:alert] = e.message
    render :action => 'new'
  end

  def destroy
    cookies.delete(:user_id)
    redirect_to root_url, :notice => "You have been logged out."
  end
  
  def new_recovery
  end
    
  def recovery
    user = User.find_by_username(params[:login]) || User.find_by_email(params[:login])
    if user
      random_password = User.generate_random_key
      user.password = random_password
      user.password_confirmation = random_password
      if user.save
        UserMailer.user_recovery(user,random_password).deliver
        redirect_to new_user_session_url, :notice => "Your password has been changed! Please check your email."
      else
        raise "Unable to recover your account."
      end
    else
      raise "Username or email address not found."
    end
  rescue Exception => e
    flash.now[:alert] = e.message
    render :action => 'new_recovery'
  end
  
end
