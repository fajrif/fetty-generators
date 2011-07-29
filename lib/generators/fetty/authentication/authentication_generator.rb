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
          @orm = using_mongoid ? 'mongoid' : 'active_record'
          add_gem("bcrypt-ruby", :require => "bcrypt")
          generate_users
          generate_sessions
          generate_reset_passwords
          generate_mailers
          edit_application_controller
          must_load_lib_directory
          add_routes
          generate_test_unit if using_test_unit?
          generate_specs if using_rspec?
          readme "README"
        else
          print_notes("You already have User model, please remove first otherwise the authentication will not work!","Error",:red)
        end
      rescue Exception => e
          print_notes(e.message,"error",:red)
      end
      
private
      
      def generate_users
        # controller & others
        copy_file "controllers/users_controller.rb", "app/controllers/users_controller.rb"
        copy_file "helpers/users_helper.rb", "app/helpers/users_helper.rb"
        copy_file "lib/users_authentication.rb", "lib/users_authentication.rb"
        # model
        copy_file "models/#{@orm}/user.rb", "app/models/user.rb"
        migration_template "models/#{@orm}/create_users.rb", "db/migrate/create_users.rb" unless using_mongoid?
        # views
        copy_file "views/users/index.html.erb", "app/views/users/index.html.erb"
        copy_file "views/users/index.js.erb", "app/views/users/index.js.erb"
        copy_file "views/users/_table.html.erb", "app/views/users/_table.html.erb"
        copy_file "views/users/new.html.erb", "app/views/users/new.html.erb"
        copy_file "views/users/edit.html.erb", "app/views/users/edit.html.erb"
        copy_file "views/users/show.html.erb", "app/views/users/show.html.erb"
      rescue Exception => e
        raise e
      end
      
      def generate_sessions
        #controller & others
        copy_file "controllers/sessions_controller.rb", "app/controllers/sessions_controller.rb"
        copy_file "helpers/sessions_helper.rb", "app/helpers/sessions_helper.rb"
        copy_file "lib/sessions_authentication.rb", "lib/sessions_authentication.rb"
        # views
        copy_file "views/sessions/new.html.erb", "app/views/sessions/new.html.erb"
      rescue Exception => e
        raise e
      end
      
      def generate_reset_passwords
        #controller & others
        copy_file "controllers/reset_passwords_controller.rb", "app/controllers/reset_passwords_controller.rb"
        copy_file "helpers/reset_passwords_helper.rb", "app/helpers/reset_passwords_helper.rb"
        # views
        copy_file "views/reset_passwords/new.html.erb", "app/views/reset_passwords/new.html.erb"
        copy_file "views/reset_passwords/edit.html.erb", "app/views/reset_passwords/edit.html.erb"
      rescue Exception => e
        raise e
      end
      
      def generate_mailers
        copy_file "mailers/user_mailer.rb", "app/mailers/user_mailer.rb"
        copy_file "mailers/setup_mail.rb", "config/initializers/setup_mail.rb"
        copy_file "views/user_mailer/user_activation.text.erb", "app/views/user_mailer/user_activation.text.erb"
        copy_file "views/user_mailer/user_forgot_password.text.erb", "app/views/user_mailer/user_forgot_password.text.erb"
      rescue Exception => e
        raise e
      end
      
      def edit_application_controller
        inject_into_file "app/controllers/application_controller.rb", :after => "ActionController::Base" do
            "\n\t include SessionsAuthentication" +
            "\n\t before_filter :authenticate_user!"
        end
      rescue Exception => e
        raise e
      end
      
      def add_routes
         inject_into_file "config/routes.rb", :after => "Application.routes.draw do" do
           "\n\n\t resources :users do" +
           "\n\t   collection do" +
           "\n\t     get 'activate/:id/:token' => 'users#activate', :as => 'activate'" +
           "\n\t     resource :session, :only => [:new, :destroy, :create]" +
           "\n\t     resource :reset_password, :only => [:new, :create, :update] do" +
           "\n\t       get ':id/:token' => 'reset_passwords#edit', :on => :collection, :as => 'edit'" +
           "\n\t     end" +
           "\n\t   end" +
           "\n\t end\n"
         end
      end
      
      def generate_test_unit
        
      end
      
      def generate_specs
        copy_file "spec/controllers/users_controller_spec.rb", "spec/controllers/users_controller_spec.rb"
        copy_file "spec/models/user_spec.rb", "spec/models/user_spec.rb"
        copy_file "spec/routing/users_routing_spec.rb", "spec/routing/users_routing_spec.rb"
        
        copy_file "spec/support/user_factories.rb", "spec/support/user_factories.rb"
        
        copy_file "spec/controllers/sessions_controller_spec.rb", "spec/controllers/sessions_controller_spec.rb"
        copy_file "spec/routing/sessions_routing_spec.rb", "spec/routing/sessions_routing_spec.rb"
        
        copy_file "spec/controllers/reset_passwords_controller_spec.rb", "spec/controllers/reset_passwords_controller_spec.rb"
        copy_file "spec/routing/reset_passwords_routing_spec.rb", "spec/routing/reset_passwords_routing_spec.rb"
      rescue Exception => e
        raise e
      end
      
      # FIXME: Should be proxied to ActiveRecord::Generators::Base
      # Implement the required interface for Rails::Generators::Migration.
      def self.next_migration_number(dirname) #:nodoc:
        ActiveRecord::Generators::Base.next_migration_number(dirname)
      end
    end
  end
end
