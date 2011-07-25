class User < ActiveRecord::Base
  
  attr_accessible :username, :email, :password, :password_confirmation, :activated_at, :token
  
  validates_presence_of :username, :email
  validates_uniqueness_of :username, :email
  validates_format_of :username, :with => /\A[-\w\._@]+\z/i, :message => "should only contain letters, numbers, or .-_@"
  validates_format_of :email, :with => /\A[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}\z/i, :message => "not a valid email address"
  validates_presence_of :password, :on => :create
  validates_confirmation_of :password
  validates_length_of :password, :minimum => 6
  
  include UsersAuthentication
  
end
