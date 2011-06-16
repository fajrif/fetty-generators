require 'generators/fetty'
require 'rails/generators/active_record'
require 'rails/generators/migration'
require 'rails/generators/generated_attribute'

module Fetty
  module Generators
    class MailboxGenerator < Base
      include Rails::Generators::Migration
      
      argument :user_class_name, :type => :string, :banner => 'user model', :default => "User"
      argument :user_object_name, :type => :string, :banner => 'user object name', :default => "current_user"
      argument :user_attribute, :type => :string, :banner => 'display attribute name', :default => "email"
      
      def generate_mailbox
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
        copy_file 'models/active_record/message_copies.rb', 'app/models/message_copy.rb'
        
        inject_into_file @model_path, :after => "ActiveRecord::Base" do
            "\n\t has_many  :sent_messages, :as => :sent_messageable, :class_name => 'MessageCopy', :dependent => :destroy" +
            "\n\t has_many  :received_messages, :as => :received_messageable, :class_name => 'Message', :dependent => :destroy" +         
            "\n\t include MailboxesHelper::Methods"
        end
      end
      
      def copy_migrations
	      migration_template 'models/active_record/create_messages_table.rb', 'db/migrate/create_messages_table.rb'
	      migration_template 'models/active_record/create_message_copies_table.rb', 'db/migrate/create_message_copies_table.rb'
	    end
      
      def copy_controller_and_helper
        template 'controllers/active_record/mailboxes_controller.rb', 'app/controllers/mailboxes_controller.rb'
        copy_file 'helpers/mailboxes_helper.rb', 'app/helpers/mailboxes_helper.rb'
      end

      def copy_views
        copy_file "views/_head.html.erb", "app/views/mailboxes/_head.html.erb"
        copy_file "views/_messages.html.erb", "app/views/mailboxes/_messages.html.erb"
        copy_file "views/_tabs_panel.html.erb", "app/views/mailboxes/_tabs_panel.html.erb"
        copy_file "views/index.html.erb", "app/views/mailboxes/index.html.erb"
        copy_file "views/index.js.erb", "app/views/mailboxes/index.js.erb"
        copy_file "views/new.html.erb", "app/views/mailboxes/new.html.erb"
        copy_file "views/show.html.erb", "app/views/mailboxes/show.html.erb"
      end

      def copy_assets
        copy_file 'assets/stylesheets/mailboxes.css', 'public/stylesheets/mailboxes.css'
        copy_file 'assets/stylesheets/token-input-facebook.css', 'public/stylesheets/token-input-facebook.css'
        copy_file 'assets/javascripts/mailboxes.js', 'public/javascripts/mailboxes.js'
        copy_file 'assets/javascripts/jquery.tokeninput.js', 'public/javascripts/jquery.tokeninput.js'
      end
	
      def add_routes
        route 'get "/mailboxes" => "mailboxes#index", :as => "mailboxes"'
        route  'get "/mailboxes/:mailbox" => "mailboxes#index", :as => "box_mailboxes"'
        route  'get "/mailbox/new" => "mailboxes#new", :as => "new_mailboxes"'
        route  'post "/mailbox/create" => "mailboxes#create", :as => "create_mailboxes"'
        route  'post "/mailbox/update" => "mailboxes#update", :as => "update_mailboxes"'
        route  'get "/mailbox/token" => "mailboxes#token", :as => "token_mailboxes"'
        route  'get "/mailbox/show/:mailbox/:id" => "mailboxes#show", :as => "show_mailboxes"'
      end

      # FIXME: Should be proxied to ActiveRecord::Generators::Base
      # Implement the required interface for Rails::Generators::Migration.
      def self.next_migration_number(dirname) #:nodoc:
        ActiveRecord::Generators::Base.next_migration_number(dirname)
      end
    end
  end
end
