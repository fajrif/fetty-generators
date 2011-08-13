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
        print_notes(e.message,"error",:red)
      end
      
private
      
      def generate_layout
        copy_file 'application.html.erb', "app/views/layouts/application.html.erb"
        copy_file 'application.css', "public/stylesheets/application.css"
        copy_file 'layout_helper.rb', 'app/helpers/layout_helper.rb'
        copy_file 'error_messages_helper.rb', 'app/helpers/error_messages_helper.rb'
        copy_file 'application.js', 'public/javascripts/application.js'
        copy_file 'application_helper.rb', 'app/helpers/application_helper.rb'
        copy_file 'down_arrow.gif', 'public/images/down_arrow.gif'
        copy_file 'up_arrow.gif', 'public/images/up_arrow.gif'
      rescue Exception => e
        raise e
      end
      
      def erb_to_haml
        asking "Are you sure want to convert all your views from ERB to HAML ?" do
          # => Cycles through the views folder and searches for erb files
          # prepare_convert_gems
          # Dir.glob("app/views/**/*.erb").each do |file|
          #   puts "Convert ERB: #{file}"
          #   unless file_exists? file.gsub(/erb$/, "haml")
          #     `html2haml #{file} | cat > #{file.gsub(/erb$/, "haml")}`
          #     File.delete(file)
          #   end
          # end
        end
      rescue Exception => e
        raise e
      end
      
      def haml_to_erb
        asking "Are you sure want to convert all your views from HAML to ERB ? [yes]" do
          # => Cycles through the views folder and searches for haml files
        end
      rescue Exception => e
        raise e
      end
      
      def prepare_convert_gems
        # install_gem "haml-rails" unless check_installed_gem? "haml-rails"
        # install_gem "hpricot" unless check_installed_gem? "hpricot"
        # install_gem "ruby_parser" unless check_installed_gem? "ruby_parser"
      rescue Exception => e
        raise e
      end
      
      def convert_views(in_type,out_type)
        # Dir["app/views/**/*.#{in_type}"].each do |file_name|
        #   puts "Convert #{first_type.capitalize}: #{file_name}"
        #   out_file_name = file_name.gsub(/#{first_type}$/, second_type)
        #   unless file_exists? out_file_name
        #     erb_string = File.open(file_name).read
        #     haml_string = Haml::HTML.new(erb_string, :erb => true).render
        #     f = File.new(haml_file_name, "w")
        #     f.write(haml_string)
        #     File.delete(file_name)
        #   end
        # end
      rescue Exception => e
        raise e
      end
      
    end
  end
end
