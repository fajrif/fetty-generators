require 'generators/fetty'

module Fetty
  module Generators
    class ViewsGenerator < Base
      
      argument :arg, :type => :string, :required => true, :banner => 'layout | erb_to_haml'
      
      def generate_views
        case arg
        when "layout"
          generate_layout
        when "erb_to_haml"
          erb_to_haml
        end
      rescue Exception => e
        print_notes(e.message,"error",:red)
      end
      
private
      
      def generate_layout
        template 'application.html.erb', "app/views/layouts/application.html.erb"
        copy_file 'application_helper.rb', 'app/helpers/application_helper.rb'
        copy_file 'layout_helper.rb', 'app/helpers/layout_helper.rb'
        copy_file 'error_messages_helper.rb', 'app/helpers/error_messages_helper.rb'
        copy_asset 'application.css', 'public/stylesheets/application.css'
        copy_asset 'application.js', 'public/javascripts/application.js'
        copy_asset 'down_arrow.gif', 'public/images/down_arrow.gif'
        copy_asset 'up_arrow.gif', 'public/images/up_arrow.gif'
      rescue Exception => e
        raise e
      end
      
      def erb_to_haml
        asking "Are you sure want to convert all your views from ERB to HAML ?" do
          # => Cycles through the views folder and searches for erb files
          prepare_convert_gems
          ::Bundler.with_clean_env do
            Dir.glob("app/views/**/*.erb").each do |file|
              out_file = file.gsub(/erb$/, "haml")
              unless file_exists? out_file
                puts "Convert ERB: #{file} => HAML: #{out_file}"
                `html2haml #{file} | cat > #{out_file}`
                File.delete(file) if $? == 0
              else
                puts "WARNING: '#{out_file}' already exists!"
              end
            end
          end
        end
      rescue Exception => e
        raise e
      end
      
      def prepare_convert_gems
        gem "haml-rails"
        install_local_gem "hpricot" unless check_local_gem? "hpricot"
        install_local_gem "ruby_parser" unless check_local_gem? "ruby_parser"
      rescue Exception => e
        raise e
      end
      
      
    end
  end
end
