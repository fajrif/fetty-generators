require 'generators/fetty'

module Fetty
  module Generators
    class LayoutGenerator < Base
      argument :layout_name, :type => :string, :default => 'application', :banner => 'layout_name'

      class_option :haml, :desc => 'Generate HAML for view, and SASS for stylesheet.', :type => :boolean
      class_option :with_devise_links, :desc => 'Generate Devise links in your application layout.', :type => :boolean, :default => true
       
      def create_layout
      	%w( "app/views/layouts/application.html.erb" "app/views/layouts/#{file_name}.html.haml" "app/views/layouts/#{file_name}.html.erb" ).each do |path|
      		FileUtils.rm path if file_exists?(path) 
  		end
      	
        if options.haml?
        	if options.with_devise_links?
        		template 'layout.html.haml', "app/views/layouts/#{file_name}.html.haml"
        	else
        		template 'no-devise-links-layout.html.haml', "app/views/layouts/#{file_name}.html.haml"
        	end	
          copy_file 'stylesheet.sass', "public/stylesheets/sass/#{file_name}.sass"
        else
        	if options.with_devise_links?
        		template 'layout.html.erb', "app/views/layouts/#{file_name}.html.erb"
        	else
        		template 'no-devise-links-layout.html.erb', "app/views/layouts/#{file_name}.html.erb"
        	end
          copy_file 'stylesheet.css', "public/stylesheets/#{file_name}.css"
        end
        copy_file 'layout_helper.rb', 'app/helpers/layout_helper.rb'
        copy_file 'error_messages_helper.rb', 'app/helpers/error_messages_helper.rb'
        copy_file 'application.js', 'public/javascripts/application.js'
      end

private

      def file_name
        layout_name.underscore
      end
      
    end
  end
end
