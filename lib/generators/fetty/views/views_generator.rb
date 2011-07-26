require 'generators/fetty'

module Fetty
  module Generators
    class ViewsGenerator < Base
      
      argument :arg, :type => :string, :required => true, :banner => 'layout | erb:to:haml | haml:to:erb'
      
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
        copy_file 'application.html.erb', "app/views/layouts/application.html.erb"
        copy_file 'application.css', "public/stylesheets/application.css"
        copy_file 'down_arrow.gif', "public/images/down_arrow.gif"
        copy_file 'down_up.gif', "public/images/down_up.gif"
        copy_file 'layout_helper.rb', 'app/helpers/layout_helper.rb'
        copy_file 'error_messages_helper.rb', 'app/helpers/error_messages_helper.rb'
        copy_file 'application.js', 'public/javascripts/application.js'
      rescue Exception => e
        raise e
      end
      
      def erb_to_haml
        print_notes("It will convert your *.html.erb files in 'app/views' to *.html.haml")
      rescue Exception => e
        raise e
      end
      
      def haml_to_erb
        print_notes("It will convert your *.html.haml files in 'app/views' to *.html.erb")
      rescue Exception => e
        raise e        
      end
      
    end
  end
end
