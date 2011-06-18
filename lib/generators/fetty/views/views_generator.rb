require 'generators/fetty'

module Fetty
  module Generators
    class ViewsGenerator < Base
      
      argument :arg, :type => :string, :required => true, :banner => 'layout | erb:to:haml | haml:to:erb'
      
      class_option :layout_name, :desc => 'The layout name you wish to set.', :type => :string, :default => 'application'
      class_option :auth_links, :desc => 'Include Authentication links in your application layout.', :type => :boolean, :default => true
      class_option :inbox_links, :desc => 'Include inbox links in your application layout.', :type => :boolean, :default => true
      class_option :search_box, :desc => 'Include search box at the top of the layout.', :type => :boolean, :default => false
      
      def generate_views
        case arg
        when "layout"
          generate_layout
        when "erb:to:haml"
          erb_to_haml
        when "haml:to:erb"
          haml_to_erb  
        end
      rescue Exception => e
        puts e.message
      end 
 
private

      def generate_layout
        %w( "app/views/layouts/application.html.erb" "app/views/layouts/#{file_name}.html.erb").each do |path|
          destroy(path) 
        end
  
        template 'application.html.erb', "app/views/layouts/#{file_name}.html.erb"
  
        copy_file 'stylesheet.css', "public/stylesheets/#{file_name}.css"
        copy_file 'layout_helper.rb', 'app/helpers/layout_helper.rb'
        copy_file 'error_messages_helper.rb', 'app/helpers/error_messages_helper.rb'
        copy_file 'application.js', 'public/javascripts/application.js'
      rescue Exception => e
        raise e
      end
      
      def erb_to_haml
        print_notes("will convert your *.html.erb files in 'app/views' to *.html.haml")
      rescue Exception => e
        raise e
      end
      
      def haml_to_erb
        print_notes("will convert your *.html.haml files in 'app/views' to *.html.erb")
      rescue Exception => e
        raise e        
      end

      def file_name
        options.layout_name.underscore
      end
      
    end
  end
end
