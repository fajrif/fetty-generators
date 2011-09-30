module UsersAuthentication
  
  module ClassMethods
    
    def authenticate!(login, pass)
      user = first(:conditions => { :username => login }) || first(:conditions => { :email => login })
      case
      when user.nil? then return UsersAuthentication::Status::Unexist
      when !user.password_match?(pass) then return UsersAuthentication::Status::InvalidPassword
      when !user.activated? then return UsersAuthentication::Status::Inactivated
      else
        return user
      end
    end
    
    def activate!(id,token)
      user = first(:conditions => { :id => id, :token => token })
      case
      when user.nil? then return UsersAuthentication::Status::Unexist
      when user.activated? then return UsersAuthentication::Status::Activated
      else
        user.update_attribute(:activated_at, Time.now.utc)
        user.clear_token!
        return user
      end
    end
    
  end
  
  module InstanceMethods
    
    def send_activation_mail
      UserMailer.user_activation(self).deliver
    end
    
    def send_forgot_password_instructions!
      self.make_token!
      UserMailer.user_forgot_password(self).deliver
    end
    
    def reset_password(new_pass,new_pass_conf)
      self.password = new_pass
      self.password_confirmation = new_pass_conf
      self.save
      unless self.password_match?(new_pass)
        return Status::Error
      else
        self.clear_token!
        return Status::Valid
      end
    end
    
    def password_match?(pass)
      self.password_hash == encrypt_password(pass)
    end
    
    def activated?
      !self.activated_at.nil?
    end
    
    def make_token!
      self.update_attribute(:token, generate_token)
    end
    
    def clear_token!
      self.update_attribute(:token, nil)
    end
    
    private
    
    def generate_token
      SecureRandom.urlsafe_base64
    end
    
    def encrypt_password(pass)
      BCrypt::Engine.hash_secret(pass, self.password_salt)
    end
    
    def prepare_password
      unless password.blank?
        self.password_salt = BCrypt::Engine.generate_salt
        self.password_hash = encrypt_password(password)
      end
    end
    
    def prepare_activation
      self.token = generate_token
    end
    
  end
  
  def self.included(receiver)
    receiver.send :attr_accessor, :password, :password_confirmation
    receiver.send :before_save, :prepare_password
    receiver.send :before_create, :prepare_activation
    
    receiver.extend ClassMethods
    receiver.send :include, InstanceMethods
  end
  
  class Status
    Valid = 0
    Unexist = 1
    InvalidPassword = 2
    Inactivated = 3
    Activated = 4
    Error = 5
  end
  
end