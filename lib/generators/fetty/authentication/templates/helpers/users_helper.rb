module UsersHelper
  
  module Authentications
    module UserMethods
        attr_accessor :password
        before_save :prepare_password, :prepare_activation

        validates_presence_of :username
        validates_uniqueness_of :username, :email, :allow_blank => true
        validates_format_of :username, :with => /^[-\w\._@]+$/i, :allow_blank => true, :message => "should only contain letters, numbers, or .-_@"
        validates_format_of :email, :with => /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i
        validates_presence_of :password, :on => :create
        validates_confirmation_of :password
        validates_length_of :password, :minimum => 4, :allow_blank => true

        # login can be either username or email address
        def self.authenticate(login, pass)
          user = find_by_username(login) || find_by_email(login)
          return user if user && user.password_hash == user.encrypt_password(pass)
        end

        def self.generate_random_key(length = 6)
          chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
          key = ""
          1.upto(length) { |i| key << chars[rand(chars.size-1)] }
          return key
        end

        def encrypt_password(pass)
          BCrypt::Engine.hash_secret(pass, password_salt)
        end

        def activated?
          if self.activated
            return true
          else
            return false
          end
        end

      private

        def prepare_password
          unless password.blank?
            self.password_salt = BCrypt::Engine.generate_salt
            self.password_hash = encrypt_password(password)
          end
        end

        def prepare_activation
          if activation_code.blank?
            self.activation_code = User.generate_random_key(12)
          end
        end
    end
  end
end
