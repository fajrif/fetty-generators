require 'generators/fetty'
require 'rails/generators/active_record'
require 'rails/generators/migration'
require 'rails/generators/generated_attribute'

module Fetty
  module Generators
    class AuthenticationGenerator < Base
      include Rails::Generators::Migration
      
      class_option :destroy, :desc => 'Destroy fetty:authentication', :type => :boolean, :default => false
      
      def generate_authentication
        if options.destroy?
          destroy_authentication
        else
          unless using_fetty_authentication?
            @orm = using_mongoid? ? 'mongoid' : 'active_record'
            add_gem("bcrypt-ruby", :require => "bcrypt")
            generate_users
            generate_sessions
            generate_reset_passwords
            generate_mailers
            edit_application_controller
            must_load_lib_directory
            add_routes
            copy_file "views/layouts/application.html.erb", "app/views/layouts/application.html.erb"
            generate_test_unit if using_test_unit?
            generate_specs if using_rspec?
            print_notes "Make sure you have defined root_url in your 'config/routes.rb.'"
          else
            raise "You already have User model, please remove first!!"
          end
        end
      rescue Exception => e
          print_notes(e.message,"error",:red)
      end
      
private
      
      def generate_users
        copy_file "controllers/users_controller.rb", "app/controllers/users_controller.rb"
        copy_file "helpers/users_helper.rb", "app/helpers/users_helper.rb"
        copy_file "lib/users_authentication.rb", "lib/users_authentication.rb"
        copy_file "models/#{@orm}/user.rb", "app/models/user.rb"
        migration_template "models/#{@orm}/create_users.rb", "db/migrate/create_users.rb" unless using_mongoid?
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
        copy_file "controllers/sessions_controller.rb", "app/controllers/sessions_controller.rb"
        copy_file "helpers/sessions_helper.rb", "app/helpers/sessions_helper.rb"
        copy_file "lib/sessions_authentication.rb", "lib/sessions_authentication.rb"
        copy_file "views/sessions/new.html.erb", "app/views/sessions/new.html.erb"
      rescue Exception => e
        raise e
      end
      
      def generate_reset_passwords
        copy_file "controllers/reset_passwords_controller.rb", "app/controllers/reset_passwords_controller.rb"
        copy_file "helpers/reset_passwords_helper.rb", "app/helpers/reset_passwords_helper.rb"
        copy_file "views/reset_passwords/new.html.erb", "app/views/reset_passwords/new.html.erb"
        copy_file "views/reset_passwords/edit.html.erb", "app/views/reset_passwords/edit.html.erb"
      rescue Exception => e
        raise e
      end
      
      def generate_mailers
        copy_file "mailers/user_mailer.rb", "app/mailers/user_mailer.rb"
        copy_file "mailers/setup_mail.rb", "config/initializers/setup_mail.rb"
        print_notes "You need to change or edit 'config/initializers/setup_mail.rb'"
        copy_file "views/user_mailer/user_activation.text.erb", "app/views/user_mailer/user_activation.text.erb"
        copy_file "views/user_mailer/user_forgot_password.text.erb", "app/views/user_mailer/user_forgot_password.text.erb"
      rescue Exception => e
        raise e
      end
      
      def edit_application_controller
        inject_into_class "app/controllers/application_controller.rb", ApplicationController do
            "  include SessionsAuthentication\n" +
            "  before_filter :authenticate_user!\n"
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
      
      def destroy_authentication
        asking "Are you sure want to destroy fetty:authentication?" do
          remove_file 'app/controllers/users_controller.rb'
          remove_file 'app/helpers/users_helper.rb'
          remove_file 'lib/users_authentication.rb'
          remove_file 'app/models/user.rb'
          run('rm db/migrate/*_create_users.rb')
          remove_dir 'app/views/users'
          remove_file 'app/controllers/sessions_controller.rb'
          remove_file 'app/helpers/sessions_helper.rb'
          remove_file 'lib/sessions_authentication.rb'
          remove_dir 'app/views/sessions'
          remove_file 'app/controllers/reset_passwords_controller.rb'
          remove_file 'app/helpers/reset_passwords_helper.rb'
          remove_dir 'app/views/reset_passwords'
          remove_file 'app/mailers/user_mailer.rb'
          remove_file 'config/initializers/setup_mail.rb'
          remove_dir 'app/views/user_mailer'
          
          gsub_file 'app/controllers/application_controller.rb', /include SessionsAuthentication.*:authenticate_user!/m, ''
          gsub_file 'config/routes.rb', /resources :users.*(\s*end){3}/m, ''
          
          if using_test_unit?
            
          end
          
          if using_rspec?
            remove_file 'spec/controllers/users_controller_spec.rb'
            remove_file 'spec/models/user_spec.rb'
            remove_file 'spec/routing/users_routing_spec.rb'
            remove_file 'spec/support/user_factories.rb'
            remove_file 'spec/controllers/sessions_controller_spec.rb'
            remove_file 'spec/routing/sessions_routing_spec.rb'
            remove_file 'spec/controllers/reset_passwords_controller_spec.rb'
            remove_file 'spec/routing/reset_passwords_routing_spec.rb'
          end
        end
      end
      
      # FIXME: Should be proxied to ActiveRecord::Generators::Base
      # Implement the required interface for Rails::Generators::Migration.
      def self.next_migration_number(dirname) #:nodoc:
        ActiveRecord::Generators::Base.next_migration_number(dirname)
      end
    end
  end
end
