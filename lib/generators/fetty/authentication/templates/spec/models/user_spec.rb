require 'spec_helper'

describe User do
  
  before(:each) do
    @user = User.new
    @user.attributes = Factory.attributes_for(:user)
  end
  
  it "should be valid" do
    @user.should be_valid
  end
  
  it "should have error on username if username is nil" do
    @user.username = nil
    @user.should have(2).error_on(:username)
  end
  
  it "should have error on email if email is nil" do
    @user.email = nil
    @user.should have(2).error_on(:email)
  end
  
  it "should have error on email if email is not a valid email address" do
    @user.email = "some_email"
    @user.should have(1).error_on(:email)
  end
  
  it "should have error on password / password_confirmation if password is nil" do
    @user.password = nil
    @user.password_confirmation = nil
    @user.should have(2).error_on(:password)
  end
  
  it "should have error on password / password_confirmation if password is less than 6" do
    @user.password = "123"
    @user.password_confirmation = "123"
    @user.should have(1).error_on(:password)
  end
  
  it "should have unique username / email in the database" do
    user = Factory(:user)
    @user.save
    @user.should have(1).error_on(:username) && have(1).error_on(:email)
  end
  
end

describe User, "Authentication Methods" do
  
  before(:each) do
    @user = Factory(:user, :username => "fajri", :password => "secret")
  end
  
  # check class method authenticate!
  it "should authenticate with matching username and password" do
    @user.activated_at = Date.today
    @user.save
    User.authenticate!('fajri', 'secret').should eql(@user)
  end
  
  it "should not authenticate with incorrect password" do
    User.authenticate!('fajri', 'incorrect').should be(UsersAuthentication::Status::InvalidPassword)
  end
  
  it "should not authenticate if record not activated" do
    User.authenticate!('fajri', 'secret').should be(UsersAuthentication::Status::Inactivated)
  end
  
  # check class method activate!
  it "should activate with matching id and token" do
    User.activate!(@user.id,@user.token).should eql(@user)
  end
  
  it "should not activate if user record not exists" do
    User.activate!("id","token").should be(UsersAuthentication::Status::Unexist)
  end
  
  it "should not activate if user already active" do
    user = User.activate!(@user.id,@user.token)
    User.activate!(user.id,user.token).should be(UsersAuthentication::Status::Activated)
  end
  
end

describe User, "Reset Password Methods" do
  
  before(:each) do
    @user = Factory(:user, :username => "fajri", :password => "secret")
    @user = User.activate!(@user.id,@user.token)
    @user.make_token!
  end
  
  it "should be able to reset password with given id and token" do
    user = User.first(:conditions => { :id => @user.id, :token => @user.token })
    user.should_not be_nil
  end
  
  it "should not be able to reset password if id and token are not exists" do
    user = User.first(:conditions => { :id => "id", :token => "token" })
    user.should be_nil
  end
  
  it "should change password if given new password are correct" do
    user = User.first(:conditions => { :id => @user.id, :token => @user.token })
    user.reset_password("123456","123456").should be(UsersAuthentication::Status::Valid)
  end
  
  it "should not change password if given new password less than 6" do
    user = User.first(:conditions => { :id => @user.id, :token => @user.token })
    user.reset_password("123","123").should_not be(UsersAuthentication::Status::Valid)
  end
  
end