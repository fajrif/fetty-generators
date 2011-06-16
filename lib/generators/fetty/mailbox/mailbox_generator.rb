require 'generators/fetty'
require 'rails/generators/migration'
require 'rails/generators/generated_attribute'

module Fetty
  module Generators
    class MailboxGenerator < Base
      include Rails::Generators::Migration
      
      argument :user_model, :type => :string, :banner => 'User Model', :default => "User"
      
      def generate_mailbox
        begin
          copy_models
          copy_migrations      
          copy_controller_and_helper
          copy_views_and_others
        rescue Exception => e
          puts e.message
        end
      end

private 
      
      def copy_models
        copy_file 'models/active_record/message.rb', 'app/models/message.rb'
        copy_file 'models/active_record/message_copies.rb', 'app/models/message_copies.rb'
        
        # inject this inside User model
        # has_many  :sent_messages, 
        #           :as => :sent_messageable,
        #           :class_name => "MessageCopy", 
        #           :dependent => :destroy
        # 
        # has_many  :received_messages, 
        #           :as => :received_messageable, 
        #           :class_name => "Message", 
        #           :dependent => :destroy
        #        
        # include MailboxesHelper::Methods
        
      end
      
      def copy_migrations
	      migration_template 'models/active_record/create_messages_table.rb', 'db/migrate/create_messages_table.rb'
	      migration_template 'models/active_record/create_message_copies_table.rb', 'db/migrate/create_message_copies_table.rb'
	    end
      
      def copy_controller_and_helper
        copy_file 'controllers/active_record/mailboxes_controller.rb', 'app/controllers/mailboxes_controller.rb'
        copy_file 'helpers/helper.rb', 'app/helpers/mailboxes_helper.rb'
      end
      
      def copy_stylesheet
				copy_file 'assets/stylesheets/mailboxes.css', 'public/stylesheets/mailboxes.css'
				copy_file 'assets/stylesheets/token-input-facebook.css', 'public/stylesheets/token-input-facebook.css'
			end
			
			def copy_javascript
				copy_file 'assets/javascripts/mailboxes.js', 'public/javascripts/mailboxes.js'
				copy_file 'assets/javascripts/jquery.tokeninput.js', 'public/javascripts/jquery.tokeninput.js'
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
			
      
      # FIXME: Should be proxied to ActiveRecord::Generators::Base
      # Implement the required interface for Rails::Generators::Migration.
      def self.next_migration_number(dirname) #:nodoc:
        ActiveRecord::Generators::Base.next_migration_number(dirname)
      end
    end
  end
end
