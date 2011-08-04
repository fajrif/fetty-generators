require 'spec_helper'

describe MessagesController do
  before(:each) do
    stub_authenticate_user
    @user = Factory(:user)
    controller.stub(:current_user).and_return(@user)
  end
  
  describe "GET index" do
    it "should render index template" do
      get :index
      response.should render_template(:index)
    end
  end
  
  describe "GET new" do
    it "should render new message template" do
      get :new
      response.should render_template(:new)
    end
  end
  
  describe "POST create" do
    describe "with valid params" do
      it "should create message and redirect to index page" do
        post :create, :user_tokens => @user.id.to_s, :subject => "testing", :content => "test message!!!"
        change{Message.count}.from(0).to(2)
        flash[:notice].should_not be_nil
        response.should redirect_to(box_messages_path(:inbox))
      end
    end
    
    describe "with invalid params" do
      it "should not create message and re-render the new template" do
        post :create
        flash[:alert].should_not be_nil
        response.should render_template(:new)
      end
    end
  end
  
  describe "GET show" do
    it "should assigns @messages" do
      # pending
    end
  end
  
  describe "GET token" do
    it "should respond json format" do
      # pending
    end
  end
  
  describe "PUT update" do
    
    describe "with valid params" do
      it "should update message Read, Unread, Delete, Undelete" do
        # pending
      end
    end
  
    describe "with invalid params" do
      it "should update message Read, Unread, Delete, Undelete" do
        # pending
      end
    end
  end
  
  describe "POST empty" do
    describe "with valid params" do
      it "should delete all messages" do
        # pending
      end
    end
  end
  
end