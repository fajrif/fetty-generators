require 'generators/fetty'

module Fetty
  module Generators
    class LayoutGenerator < Base
      argument :layout_name, :desc => 'The layout name you wish to set.', :type => :string, :default => 'application'
      
      class_option :auth_links, :desc => 'Include Authentication links in your application layout.', :type => :boolean, :default => true
      class_option :mailbox_links, :desc => 'Include Mailboxes links in your application layout.', :type => :boolean, :default => true
       
      # def create_layout
      #         %w( "app/views/layouts/application.html.erb" "app/views/layouts/#{file_name}.html.erb" "app/views/layouts/application.html.haml" "app/views/layouts/#{file_name}.html.haml" ).each do |path|
      #           destroy(path) 
      #         end
      #         
      #         template 'application.html.erb', "app/views/layouts/#{file_name}.html.erb"
      #         
      #         copy_file 'stylesheet.css', "public/stylesheets/#{file_name}.css"
      #         copy_file 'layout_helper.rb', 'app/helpers/layout_helper.rb'
      #         copy_file 'error_messages_helper.rb', 'app/helpers/error_messages_helper.rb'
      #         copy_file 'application.js', 'public/javascripts/application.js'
      #       end
      # 
private

      def file_name
        layout_name.underscore
      end
      
    end
  end
end
