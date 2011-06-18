require 'generators/fetty'
require 'rails/generators/active_record'
require 'rails/generators/migration'
require 'rails/generators/generated_attribute'

module Fetty
  module Generators
    class MessagesGenerator < Base
      include Rails::Generators::Migration
      
      argument :user_class_name, :type => :string, :banner => 'user model', :default => "User"
      argument :user_object_name, :type => :string, :banner => 'user object name', :default => "current_user"
      argument :user_attribute, :type => :string, :banner => 'display attribute name', :default => "email"
      
      def generate_messages
        # required to have User model first
        @model_path = "app/models/#{user_class_name.singularize.downcase}.rb"
        
        if file_exists?(@model_path)
          copy_models
          copy_migrations
          copy_controller_and_helper
          copy_views
          copy_assets
          add_routes
        else
          puts "You don't have User model, please install some authentication first!"
        end 
      rescue Exception => e
          puts e.message
      end

private 
      
      def copy_models
        copy_file 'models/active_record/message.rb', 'app/models/message.rb'
        copy_file 'models/active_record/message_copy.rb', 'app/models/message_copy.rb'
        
        inject_into_file @model_path, :after => "ActiveRecord::Base" do
            "\n\t has_many  :sent_messages, :as => :sent_messageable, :class_name => 'MessageCopy', :dependent => :destroy" +
            "\n\t has_many  :received_messages, :as => :received_messageable, :class_name => 'Message', :dependent => :destroy" +         
            "\n\t include MessagesHelper::Methods"
        end
      end
      
      def copy_migrations
	      migration_template 'models/active_record/create_messages.rb', 'db/migrate/create_messages.rb'
	      migration_template 'models/active_record/create_message_copies.rb', 'db/migrate/create_message_copies.rb'
	    end
      
      def copy_controller_and_helper
        template 'controllers/active_record/messages_controller.rb', 'app/controllers/messages_controller.rb'
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
       route 'put "/messages/update" => "messages#update", :as => "update_messages"'
       route 'post "/messages/create" => "messages#create", :as => "create_messages"'
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
