class UserMailer < ActionMailer::Base
  default :from => "from@example.com"

  def user_recovery(user,random_password)
    @user = user
    @random_password = random_password
    mail(:to => user.email, :subject => "Account Recovery")
  end
  
  def user_activation(user)
    @user = user
    mail(:to => user.email, :subject => "Account Activation")
  end
  
end
