require 'spec_helper'

describe UsersController do
  
  def stub_authenticate_user
    controller.stub(:authenticate_user!).and_return(true)
  end
  
  def test_assigns_user_object(action)
    user = Factory(:user)
    User.stub(:find).with(user.id.to_s).and_return(user)
    get action, :id => user.id.to_s
    assigns(:user).should eql(user)
  end
  
  def test_passing_valid_paramaters
    assigns(:user).username.should be_a_kind_of(String)
    assigns(:user).email.should be_a_kind_of(String)
    assigns(:user).password.should be_a_kind_of(String)
    assigns(:user).password_confirmation.should be_a_kind_of(String)
    assigns(:user).password.should eql(assigns(:user).password_confirmation)
  end
  
  describe "GET index" do
    it "assigns all users as @users" do
      stub_authenticate_user
      get :index
      assigns(:users).should_not be_nil
    end
  end
  
  describe "GET new" do
    it "should render sign-up page and assigns a new user as @user" do
      get :new
      assigns(:user).should be_a_new(User)
      response.should be_success
    end
    
    it "should not render sign-up page if user already sign-in" do
      controller.stub(:user_signed_in?).and_return(true)
      get :new
      flash[:alert].should_not be_nil
    end
  end
  
  describe "POST create" do
    describe "with valid params" do
      it "should create user and redirect to sign-in page" do
        User.any_instance.stub(:valid?).and_return(true)
        post :create, Factory.attributes_for(:user)
        test_passing_valid_paramaters
        assigns(:user).should_not be_new_record
        flash[:notice].should_not be_nil
        response.should redirect_to(new_session_path)
      end
    end
  
    describe "with invalid params" do
      it "should not create user and re-render the sign-up page" do
        User.any_instance.stub(:valid?).and_return(false)
        post :create
        assigns(:user).should be_new_record
        flash[:alert].should_not be_nil
        response.should render_template(:new)
      end
    end
  end
  
  describe "GET show" do
    it "should assigns the requested user as @user" do
      test_assigns_user_object :show
    end
  end
  
  describe "GET edit" do
    it "should assigns the authenticated user as @user" do
      stub_authenticate_user
      test_assigns_user_object :edit
    end
  end
  
  describe "PUT update" do
    
    before(:each) do
      stub_authenticate_user
      @user = Factory(:user)
      User.stub(:find).with(@user.id.to_s).and_return(@user)
    end
    
    describe "with valid params" do
      it "should update user and redirect back to user path" do
        User.any_instance.stub(:valid?).and_return(true)
        put :update, Factory.attributes_for(:user, :id => @user.id.to_s)
        test_passing_valid_paramaters
        assigns(:user).should eql(@user)
        flash[:notice].should_not be_nil
        response.should redirect_to(user_path(@user))
      end
    end
  
    describe "with invalid params" do
      it "should not change user and re-render page" do
        User.any_instance.stub(:valid?).and_return(false)
        put :update, :id => @user.id.to_s
        assigns(:user).should eql(@user)
        flash[:alert].should_not be_nil
        response.should render_template(:edit)
      end
    end
  end
  
  describe "DELETE destroy" do
    before(:each) do
      stub_authenticate_user
      @user = Factory(:user)
      User.stub(:find).with(@user.id.to_s).and_return(@user)
    end
    
    it "should delete self user with authenticate user and redirect to sign-in page" do
      controller.stub(:current_user).and_return(@user)
      delete :destroy, :id => @user.id.to_s
      flash[:notice].should_not be_nil
      response.should redirect_to(new_session_path)
    end
    
    it "should delete other user and redirect to users list" do
      controller.stub(:current_user).and_return(nil)
      delete :destroy, :id => @user.id.to_s
      flash[:notice].should_not be_nil
      response.should redirect_to(users_path)
    end
  end
  
  describe "GET activate" do
    before(:each) do
      @user = Factory(:user, :token => "sometoken")
    end
    
    describe "with valid params" do
      it "should activate user with given id and token and redirect to root_path" do
        User.stub(:activate!).with(@user.id.to_s, @user.token).and_return(@user)
        get :activate, :id => @user.id.to_s, :token => @user.token
        assigns(:user).should be_a(User)
        flash[:notice].should_not be_nil
        response.should redirect_to(root_path)
      end
    end
    
    describe "with invalid params" do
      it "should not activate user if user not exists" do
        User.stub(:activate!).with(@user.id.to_s, @user.token).and_return(UsersAuthentication::Status::Unexist)
        get :activate, :id => @user.id.to_s, :token => @user.token
        assigns(:user).should eql(UsersAuthentication::Status::Unexist)
      end
      
      it "should not activate user if user already active" do
        User.stub(:activate!).with(@user.id.to_s, @user.token).and_return(UsersAuthentication::Status::Activated)
        get :activate, :id => @user.id.to_s, :token => @user.token
        assigns(:user).should eql(UsersAuthentication::Status::Activated)
      end
      
      after(:each) do
        flash[:alert].should_not be_nil
        response.should redirect_to(new_session_path)
      end
    end
  end
  
end
