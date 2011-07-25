require 'spec_helper'

describe ResetPasswordsController do
  
  describe "GET new" do
    it "should render the reset password page" do
      get :new
      response.status.should eql(200)
    end
  end
  
  describe "POST create" do
    describe "with valid login" do
      it "should send reset password instructions through mail" do
        user = Factory.build(:user, :activated_at => Date.today)
        User.stub(:first).with(:conditions => { :username => "some@email.com" }).and_return(user)
        post :create, :login => "some@email.com"
        assigns(:user).should be_a(User)
        flash[:notice].should_not be_nil
      end
    end
    
    describe "with invalid login" do
      it "should not send reset password instructions if user not found" do
        User.stub(:first).with(:conditions => { :username => "some@email.com" }).and_return(nil)
        post :create, :login => "some@email.com"
        assigns(:user).should be_nil
      end
      
      it "should not send reset password instructions if user not activated" do
        user = Factory.build(:user)
        User.stub(:first).with(:conditions => { :username => "some@email.com" }).and_return(user)
        post :create, :login => "some@email.com"
        assigns(:user).should be_a(User)
        assigns(:user).activated_at.should be_nil
      end
      
      after(:each) do
        flash[:alert].should_not be_nil
      end
    end
    
    after(:each) do
      response.should render_template(:new)
    end
  end
  
  describe "GET edit" do
    before(:each) do
      @user = Factory.build(:user, :token => "sometoken")
    end
    
    it "should assigns @user and render page if given parameters are valid" do
      User.stub(:first).with(:conditions => { :id => @user.id.to_s, :token => @user.token.to_s }).and_return(@user)
      get :edit, :id => @user.id.to_s, :token => @user.token.to_s
      assigns(:user).should eql(@user)
      response.status.should eql(200)
    end
    
    it "should not render page and redirect to reset password page" do
      User.stub(:first).with(:conditions => { :id => @user.id.to_s, :token => @user.token.to_s }).and_return(nil)
      get :edit, :id => @user.id.to_s, :token => @user.token.to_s
      assigns(:user).should be_nil
      response.should redirect_to(new_reset_password_path)
    end
  end
  
  describe "PUT update" do
    describe "with valid params" do
      it "should reset password" do
        user = Factory.build(:user, :token => "sometoken")
        User.stub(:first).with(:conditions => { :id => user.id.to_s, :token => user.token.to_s }).and_return(user)
        User.any_instance.stub(:reset_password).with("secret","secret").and_return(UsersAuthentication::Status::Valid)
        put :update, :id => user.id.to_s, :token => user.token.to_s, :password => "secret", :password_confirmation => "secret"
        assigns(:user).should eql(user)
        flash[:notice].should_not be_nil
        response.should redirect_to(new_session_path)
      end
    end
    
    describe "with invalid params" do
      it "should not send reset password instructions if user not found" do
        user = Factory.build(:user, :token => "sometoken")
        User.stub(:first).with(:conditions => { :id => user.id.to_s, :token => user.token.to_s }).and_return(nil)
        put :update, :id => user.id.to_s, :token => user.token.to_s
        assigns(:user).should be_nil
        flash[:alert].should_not be_nil
        response.should render_template(:edit)
      end
    end
  end

end
