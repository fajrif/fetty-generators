require 'generators/fetty'
require 'rails/generators/active_record'
require 'rails/generators/migration'
require 'rails/generators/generated_attribute'

module Fetty
  module Generators
    class MessagesGenerator < Base
      include Rails::Generators::Migration
      
      def generate_messages
        @model_path = "app/models/user.rb"
        if file_exists?(@model_path)
          @orm = gemfile_included?("mongoid") ? 'mongoid' : 'active_record'
          add_gem("ancestry")
          copy_models_and_migrations
          copy_controller_and_helper
          copy_views
          copy_assets
          must_load_lib_directory
          add_routes
        else
          puts "You don't have User model, please install some authentication first!"
        end
      rescue Exception => e
          puts e.message
      end
      
private 
      
      def copy_models_and_migrations
        code = "\n\t has_many :messages" + "\n\t include UsersMessages"
        text = (@orm == 'active_record') ? "ActiveRecord::Base" : "include Mongoid::Timestamps"
        
        copy_file "models/#{@orm}/message.rb", "app/models/message.rb"
        migration_template "models/active_record/create_messages.rb", "db/migrate/create_messages.rb" if @orm == 'active_record'
        copy_file "lib/users_messages.rb", "lib/users_messages.rb"
        inject_into_file @model_path, code, :after => text
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
      
      # FIXME: Should be proxied to ActiveRecord::Generators::Base
      # Implement the required interface for Rails::Generators::Migration.
      def self.next_migration_number(dirname) #:nodoc:
        ActiveRecord::Generators::Base.next_migration_number(dirname)
      end
    end
  end
end
