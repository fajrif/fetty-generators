require 'spec_helper'

describe SessionsController do
  
  def stub_authenticate_user
    controller.stub(:authenticate_user!).and_return(true)
  end
  
  describe "GET new" do
    it "should render sign-in page" do
      get :new
      response.should be_success
    end
    
    it "should not render sign-in page if already sign-in" do
      controller.stub(:user_signed_in?).and_return(true)
      get :new
      flash[:alert].should_not be_nil
    end
  end
  
  describe "POST create" do
    describe "with valid params" do
      it "should authenticate user and redirect to root_path" do
        user = Factory(:user, :email => "some@email.com", :password => "secret", :password_confirmation => "secret")
        User.stub(:authenticate!).with("some@email.com", "secret").and_return(user)
        post :create, :login => "some@email.com", :password => "secret"
        assigns(:user).should be_a(User)
        assigns(:current_user).should eql(user)
        flash[:notice].should_not be_nil
        response.should redirect_to(root_path)
      end
    end
    
    describe "with invalid params" do
      it "should not authenticate if user not exists" do
        User.stub(:authenticate!).with("some@email.com", "secret").and_return(UsersAuthentication::Status::Unexist)
        post :create, :login => "some@email.com", :password => "secret"
        assigns(:user).should eql(UsersAuthentication::Status::Unexist)
      end
  
      it "should not authenticate if given password invalid" do
        User.stub(:authenticate!).with("some@email.com", "secret").and_return(UsersAuthentication::Status::InvalidPassword)
        post :create, :login => "some@email.com", :password => "secret"
        assigns(:user).should eql(UsersAuthentication::Status::InvalidPassword)
      end
  
      it "should not authenticate if user not activated" do
        User.stub(:authenticate!).with("some@email.com", "secret").and_return(UsersAuthentication::Status::Inactivated)
        post :create, :login => "some@email.com", :password => "secret"
        assigns(:user).should eql(UsersAuthentication::Status::Inactivated)
      end
      
      after(:each) do
        flash[:alert].should_not be_nil
        response.should render_template(:new)
      end
    end
  end
  
  describe "DELETE destroy" do
    it "should destroy session or cookies and redirect to root_path" do
      stub_authenticate_user
      delete :destroy
      assigns(:current_user).should be_nil
      flash[:notice].should_not be_nil
      response.should redirect_to(root_path)
    end
  end
  
end