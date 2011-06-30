class User < ActiveRecord::Base
  # new columns need to be added here to be writable through mass assignment
  attr_accessible :username, :email, :password, :password_confirmation, :activation_code, :activated
  include UsersHelper::Authentications::UserMethods
end
