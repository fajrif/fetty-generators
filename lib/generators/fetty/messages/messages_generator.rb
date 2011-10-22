require 'generators/fetty'
require 'rails/generators/active_record'
require 'rails/generators/migration'
require 'rails/generators/generated_attribute'

module Fetty
  module Generators
    class MessagesGenerator < Base
      include Rails::Generators::Migration
      
      class_option :destroy, :desc => 'Destroy fetty:messages', :type => :boolean, :default => false
      
      # have to inject this tag on application.html.erb layout
      # <%= link_to "inbox(#{current_user.inbox(:opened => false).count})", messages_path(:inbox), :id => "inbox-link" %> |
      
      def generate_messages
        if options.destroy?
          destroy_messages
        else
          @model_path = "app/models/user.rb"
          if file_exists?(@model_path)
            unless using_mongoid?
              @orm = using_mongoid? ? 'mongoid' : 'active_record'
              gem "ancestry"
              copy_models_and_migrations
              copy_controller_and_helper
              copy_views
              copy_assets
              must_load_lib_directory
              add_routes
              insert_links_on_layout
              generate_specs if using_rspec?
            else
              raise "Sorry, fetty:messages only works with ActiveRecord !!"
            end
          else
            raise "You don't have User model, please install some authentication first!"
          end
        end
      rescue Exception => e
        print_notes(e.message,"error",:red)
      end
      
private 
      
      def insert_links_on_layout
        inject_into_file "app/views/layouts/application.html.erb", :before => "<%= content_tag :h1, yield(:title) if show_title? %>" do
          "\n\t <div id='messagebox'>" +
          "\n\t   <% if user_signed_in? %>" +
          "\n\t     <%= link_to \"inbox(\#{current_user.inbox(:opened => false).count})\", messages_path(:inbox), :id => 'inbox-link' %>" +
          "\n\t   <% end %>" +
          "\n\t </div>\n"
        end
      rescue  Exception => e
        raise e
      end
      
      def copy_models_and_migrations
        copy_file "models/#{@orm}/message.rb", "app/models/message.rb"
        migration_template "models/active_record/create_messages.rb", "db/migrate/create_messages.rb" unless using_mongoid?
        copy_file "lib/users_messages.rb", "lib/users_messages.rb"
        
        inject_into_class @model_path, User do
          "\n  has_many :messages" +
          "\n  include UsersMessages\n"
        end
      end
      
      def copy_controller_and_helper
        copy_file 'controllers/messages_controller.rb', 'app/controllers/messages_controller.rb'
        copy_file 'helpers/messages_helper.rb', 'app/helpers/messages_helper.rb'
      end
      
      def copy_views
        copy_file "views/_head.html.erb", "app/views/messages/_head.html.erb"
        copy_file "views/_messages.html.erb", "app/views/messages/_messages.html.erb"
        copy_file "views/_tabs_panel.html.erb", "app/views/messages/_tabs_panel.html.erb"
        copy_file "views/index.html.erb", "app/views/messages/index.html.erb"
        copy_file "views/index.js.erb", "app/views/messages/index.js.erb"
        copy_file "views/new.html.erb", "app/views/messages/new.html.erb"
        copy_file "views/show.html.erb", "app/views/messages/show.html.erb"
      end
      
      def copy_assets
        copy_asset 'assets/stylesheets/messages.css', 'public/stylesheets/messages.css'
        copy_asset 'assets/stylesheets/token-input-facebook.css', 'public/stylesheets/token-input-facebook.css'
        copy_asset 'assets/javascripts/messages.js', 'public/javascripts/messages.js'
        copy_asset 'assets/javascripts/jquery.tokeninput.js', 'public/javascripts/jquery.tokeninput.js'
      end
      
      def add_routes
        inject_into_file "config/routes.rb", :after => "Application.routes.draw do" do
          "\n\n\t resources :messages, :only => [:new, :create] do" +
          "\n\t   collection do" +
          "\n\t     get 'token' => 'messages#token', :as => 'token'" +
          "\n\t     post 'empty/:messagebox' => 'messages#empty', :as => 'empty'" +
          "\n\t     put 'update' => 'messages#update'" +
          "\n\t     get ':messagebox/show/:id' => 'messages#show', :as => 'show', :constraints => { :messagebox => /inbox|outbox|trash/ }" +
          "\n\t     get '(/:messagebox)' => 'messages#index', :as => 'box', :constraints => { :messagebox => /inbox|outbox|trash/ }" +
          "\n\t   end" +
          "\n\t end\n"
        end
      end
      
      def generate_specs
        copy_file "spec/controllers/messages_controller_spec.rb", "spec/controllers/messages_controller_spec.rb"
        copy_file "spec/models/message_spec.rb", "spec/models/message_spec.rb"
        copy_file "spec/routing/messages_routing_spec.rb", "spec/routing/messages_routing_spec.rb"
        copy_file "spec/support/message_factories.rb", "spec/support/message_factories.rb"
      end
      
      def destroy_messages
        asking "Are you sure want to destroy fetty:messages?" do
          remove_file "app/models/message.rb"
          run('rm db/migrate/*_create_messages.rb') unless using_mongoid?
          remove_file "lib/users_messages.rb"
          gsub_file 'app/models/user.rb', /has_many :messages/, ''
          gsub_file 'app/models/user.rb', /include UsersMessages/, ''
          remove_file "app/controllers/messages_controller.rb"
          remove_file "app/helpers/messages_helper.rb"
          remove_dir "app/views/messages"
          remove_asset 'public/stylesheets/messages.css'
          remove_asset 'public/stylesheets/token-input-facebook.css'
          remove_asset 'public/javascripts/messages.js'
          remove_asset 'public/javascripts/jquery.tokeninput.js'
          gsub_file 'config/routes.rb', /resources :messages.*:constraints => { :messagebox => \/inbox|outbox|trash\/ }(\s*end){2}/m, ''
          
          if using_rspec?
            remove_file "spec/controllers/messages_controller_spec.rb"
            remove_file "spec/models/message_spec.rb"
            remove_file "spec/routing/messages_routing_spec.rb"
            remove_file "spec/support/message_factories.rb"
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
