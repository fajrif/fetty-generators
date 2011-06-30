require 'generators/fetty'
require 'rails/generators/active_record'
require 'rails/generators/migration'
require 'rails/generators/generated_attribute'

module Fetty
  module Generators
    class AuthenticationGenerator < Base
      include Rails::Generators::Migration
            
      def generate_authentication
        # @model_path = "app/models/#{user_class_name.singularize.downcase}.rb"
        # if file_exists?(@model_path)
        # else
        #   puts "You don't have User model, please install some authentication first!"
        # end
        
        add_gem("bcrypt-ruby")
        generate_users
        generate_sessions
        generate_mailers
        edit_application_controller
        add_routes
        
      rescue Exception => e
          puts e.message
      end

private 
      
      def generate_users
        copy_file 'controllers/active_record/users_controller.rb', 'app/controllers/users_controller.rb'
        copy_file 'helpers/users_helper.rb', 'app/helpers/users_helper.rb'
        copy_file 'models/active_record/user.rb', 'app/models/user.rb'        
        migration_template 'models/active_record/create_users.rb', 'db/migrate/create_users.rb'
        copy_file "views/users/new.html.erb", "app/views/users/new.html.erb"
        copy_file "views/users/edit.html.erb", "app/views/users/edit.html.erb"
        copy_file "views/users/show.html.erb", "app/views/users/show.html.erb"
      end
      
      def generate_sessions
        copy_file 'controllers/active_record/sessions_controller.rb', 'app/controllers/sessions_controller.rb'
        copy_file 'helpers/sessions_helper.rb', 'app/helpers/sessions_helper.rb'
        copy_file "views/sessions/new.html.erb", "app/views/sessions/new.html.erb"
        copy_file "views/sessions/new.html.erb", "app/views/sessions/new_recovery.html.erb"
      end
      
      def generate_mailers
        copy_file 'mailers/user_mailer.rb', 'app/mailers/user_mailer.rb'
        copy_file "views/user_mailer/user_activation.text.erb", "app/views/user_mailer/user_activation.text.erb"
        copy_file "views/user_mailer/user_recovery.text.erb", "app/views/user_mailer/user_recovery.text.erb"        
      end
      
      def edit_application_controller
        inject_into_file "app/controllers/application_controller.rb", :after => "ActionController::Base" do
            "\n\t include SessionsHelper::Authentications::SessionMethods" +
            "\n\t before_filter :authenticate_user!"
        end
      end
      
      def add_routes
        route 'get "/sign_up" => "users#new", :as => "new_user_registration"'
        route 'post "/users/create" => "users#create", :as => "create_user_registration"'
        route 'get "/users/show" => "users#show", :as => "show_user_session"'
        route 'get "/users/edit" => "users#edit", :as => "edit_user_session"'
        route 'post "/users/update" => "users#update", :as => "update_user_session"'
        route 'get "/sign_in" => "sessions#new", :as => "new_user_session"'
        route 'post "/sessions/create" => "sessions#create", :as => "create_user_session"'
        route 'get "/user_recovery" => "sessions#new_recovery", :as => "new_user_recovery"'
        route 'post "/sessions/recovery" => "sessions#recovery", :as => "create_user_recovery"'
        route 'get "/sign_out" => "sessions#destroy", :as => "destroy_user_session"'
        route 'get "/users/activate/:id/:code" => "users#activate", :as => "update_user_activation"'
      end
      
      
      # FIXME: Should be proxied to ActiveRecord::Generators::Base
      # Implement the required interface for Rails::Generators::Migration.
      def self.next_migration_number(dirname) #:nodoc:
        ActiveRecord::Generators::Base.next_migration_number(dirname)
      end
    end
  end
end
