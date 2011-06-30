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
      UserMailer.user_activation(@user).deliver
      redirect_to new_user_session_url, :notice => "Activation link has been sent to your email."
    else
      flash.now[:alert] = "Unable to create account."
      render :action => 'new'
    end
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update_attributes(:username => params[:username], :email => params[:email], :password => params[:password], :password_confirmation => params[:password_confirmation])
      redirect_to root_url, :notice => "Your profile has been updated."
    else
      flash.now[:alert] = "Unable to update your profile."
      render :action => 'edit'
    end
  end
  
  def activate
    @user = User.find_by_id_and_activation_code_and_activated(params[:id], params[:code], false)
    if @user.update_attribute('activated', true)
      cookies[:user_id] = @user.id
      redirect_to root_url, :notice => "Your account has been activated!"
    end
  end
end
