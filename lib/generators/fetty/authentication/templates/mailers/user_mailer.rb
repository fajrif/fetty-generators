class UserMailer < ActionMailer::Base
  default :from => "from@example.com"

  def user_forgot_password(user)
    @user = user
    mail(:to => user.email, :subject => "Reset Password Instructions")
  end
  
  def user_activation(user)
    @user = user
    mail(:to => user.email, :subject => "Account Activation")
  end
  
end
