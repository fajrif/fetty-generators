module SessionsHelper

  module Authentications
    module SessionMethods
      def self.included(controller)
        controller.send :helper_method, :current_user, :user_signed_in?, :redirect_to_target_or_default
      end

      def current_user
        @current_user ||= User.find(cookies[:user_id]) if cookies[:user_id]
      end

      def user_signed_in?
        if current_user
          true
        else
          false
        end
      end

      def authenticate_user!
        unless user_signed_in?
          redirect_to new_user_session_url, :alert => "You must first log in or sign up before accessing this page."
        end
      end
    end
  end
end
