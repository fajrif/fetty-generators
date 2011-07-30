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
            @orm = using_mongoid? ? 'mongoid' : 'active_record'
            using_mongoid? ? add_gem("mongoid-ancestry") : add_gem("ancestry")
            copy_models_and_migrations
            copy_controller_and_helper
            copy_views
            copy_assets
            must_load_lib_directory
            add_routes
          else
            raise "You don't have User model, please install some authentication first!"
          end
        end
      rescue Exception => e
        print_notes(e.message,"error",:red)
      end
      
private 
      
      def copy_models_and_migrations
        copy_file "models/#{@orm}/message.rb", "app/models/message.rb"
        migration_template "models/active_record/create_messages.rb", "db/migrate/create_messages.rb" unless using_mongoid?
        copy_file "lib/users_messages.rb", "lib/users_messages.rb"
        inject_into_class @model_path, User do
          "  include UsersMessages\n"
          + "  has_many :messages\n" unless using_mongoid?
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
        copy_file 'assets/stylesheets/messages.css', 'public/stylesheets/messages.css'
        copy_file 'assets/stylesheets/token-input-facebook.css', 'public/stylesheets/token-input-facebook.css'
        copy_file 'assets/javascripts/messages.js', 'public/javascripts/messages.js'
        copy_file 'assets/javascripts/jquery.tokeninput.js', 'public/javascripts/jquery.tokeninput.js'
      end
      
      def add_routes
        route 'get "/messages(/:messagebox)" => "messages#index", :as => "messages", :constraints => { :messagebox => /inbox|outbox|trash/ }'
        route 'get "/messages/:messagebox/show/:id" => "messages#show", :as => "show_messages", :constraints => { :messagebox => /inbox|outbox|trash/ }'
        route 'post "/messages/create" => "messages#create", :as => "create_messages"'
        route 'post "/messages/update" => "messages#update", :as => "update_messages"'
        route 'post "/messages/empty/:messagebox" => "messages#empty", :as => "empty_messages"'
        route 'get "/messages/new" => "messages#new", :as => "new_messages"'
        route 'get "/messages/token" => "messages#token", :as => "token_messages"'
      end
      
      def destroy_messages
        asking "Are you sure want to destroy fetty:messages?" do
          remove_file "app/models/message.rb"
          run('rm db/migrate/*_create_messages.rb') unless using_mongoid?
          remove_file "lib/users_messages.rb"
          gsub_file 'app/models/user.rb', /has_many :messages/, '' unless using_mongoid?
          gsub_file 'app/models/user.rb', /include SessionsAuthentication/, ''
          remove_file "app/controllers/messages_controller.rb"
          remove_file "app/helpers/messages_helper.rb"
          remove_dir "app/views/messages"
          remove_file 'public/stylesheets/messages.css'
          remove_file 'public/stylesheets/token-input-facebook.css'
          remove_file 'public/javascripts/messages.js'
          remove_file 'public/javascripts/jquery.tokeninput.js'
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
