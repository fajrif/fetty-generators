require 'generators/fetty'
require 'rails/generators/active_record'
require 'rails/generators/migration'
require 'rails/generators/generated_attribute'

module Fetty
  module Generators
    class AuthenticationGenerator < Base
      include Rails::Generators::Migration
      
      def generate_authentication
        
        unless file_exists?("app/models/user.rb")
          @orm = gemfile_included?("mongoid") ? 'mongoid' : 'active_record'
          add_gem("bcrypt-ruby", :require => "bcrypt")
          generate_users
          generate_sessions
          generate_mailers
          edit_application_controller
          must_load_lib_directory
          add_routes
        else
          puts "You already have User model, please remove first otherwise the authentication will not work!"
        end
        
      rescue Exception => e
          puts e.message
      end

private
      
      def generate_users
        copy_file "controllers/users_controller.rb", "app/controllers/users_controller.rb"
        copy_file "helpers/users_helper.rb", "app/helpers/users_helper.rb"
        copy_file "models/#{@orm}/user.rb", "app/models/user.rb"
        migration_template "models/#{@orm}/create_users.rb", "db/migrate/create_users.rb" if @orm == 'active_record'
        copy_file "lib/users_authentication.rb", "lib/users_authentication.rb"
        copy_file "views/users/new.html.erb", "app/views/users/new.html.erb"
        copy_file "views/users/new_forgot_password.html.erb", "app/views/users/new_forgot_password.html.erb"
        copy_file "views/users/new_reset_password.html.erb", "app/views/users/new_reset_password.html.erb"
        copy_file "views/users/edit.html.erb", "app/views/users/edit.html.erb"
        copy_file "views/users/show.html.erb", "app/views/users/show.html.erb"
      end
      
      def generate_sessions
        copy_file "controllers/sessions_controller.rb", "app/controllers/sessions_controller.rb"
        copy_file "helpers/sessions_helper.rb", "app/helpers/sessions_helper.rb"
        copy_file "lib/sessions_authentication.rb", "lib/sessions_authentication.rb"
        copy_file "views/sessions/new.html.erb", "app/views/sessions/new.html.erb"
      end
      
      def generate_mailers
        copy_file "mailers/setup_mail.rb", "app/mailers/setup_mail.rb"
        copy_file "mailers/user_mailer.rb", "app/mailers/user_mailer.rb"
        copy_file "views/user_mailer/user_activation.text.erb", "app/views/user_mailer/user_activation.text.erb"
        copy_file "views/user_mailer/user_forgot_password.text.erb", "app/views/user_mailer/user_forgot_password.text.erb"
      end
      
      def edit_application_controller
        inject_into_file "app/controllers/application_controller.rb", :after => "ActionController::Base" do
            "\n\t include SessionsAuthentication" +
            "\n\t before_filter :authenticate_user!"
        end
      end
      
      def add_routes
         route 'get "/sign_up" => "users#new", :as => "new_user_registration"'
         route 'post "/users/create" => "users#create", :as => "create_user_registration"'
         route 'get "/users/show" => "users#show", :as => "show_user_session"'
         route 'get "/users/edit" => "users#edit", :as => "edit_user_session"'
         route 'post "/users/update" => "users#update", :as => "update_user_session"'
         route 'get "/users/activate/:id/:token" => "users#activate", :as => "update_user_activation"'
         route 'get "/forgot_password" => "users#new_forgot_password", :as => "new_user_forgot_password"'
         route 'post "/users/forgot_password" => "users#forgot_password", :as => "create_user_forgot_password"'
         route 'get "/users/new_reset_password/:id/:token" => "users#new_reset_password", :as => "new_user_reset_password"'
         route 'post "/users/reset_password" => "users#reset_password", :as => "create_user_reset_password"'
         route 'get "/sign_in" => "sessions#new", :as => "new_user_session"'
         route 'post "/sessions/create" => "sessions#create", :as => "create_user_session"'
         route 'get "/sign_out" => "sessions#destroy", :as => "destroy_user_session"'
      end
      
      
      # FIXME: Should be proxied to ActiveRecord::Generators::Base
      # Implement the required interface for Rails::Generators::Migration.
      def self.next_migration_number(dirname) #:nodoc:
        ActiveRecord::Generators::Base.next_migration_number(dirname)
      end
    end
  end
end
