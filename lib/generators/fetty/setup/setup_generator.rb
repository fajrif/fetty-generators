require 'generators/fetty'

module Fetty
  module Generators
    class SetupGenerator < Base #:nodoc: 
      
      # required
      class_option :cancan, :desc => 'Install cancan for authorization', :type => :boolean, :default => true 
      class_option :jquery_rails, :desc => 'Install jquery-rails for javascript framework', :type => :boolean, :default => true
      class_option :simple_form, :desc => 'Install simple_form for generate form', :type => :boolean, :default => true
      class_option :carrierwave, :desc => 'Install carrierwave for handling file attachment', :type => :boolean, :default => true
      class_option :kaminari, :desc => 'Install kaminari for pagination', :type => :boolean, :default => true 
      class_option :ckeditor, :desc => 'Install ckeditor for WYSIWYG editor', :type => :boolean, :default => true
      class_option :meta_search, :desc => 'Install meta_search for ActiveRecord searching', :type => :boolean, :default => true
      class_option :faker, :desc => 'Install faker to help you populate data', :type => :boolean, :default => true
      
      # optional
      class_option :mongoid, :desc => 'Install mongoid for replacing your ORM', :type => :boolean, :default => false
      class_option :devise, :desc => 'Install devise for authentication', :type => :boolean, :default => false 
      class_option :thinking_sphinx, :desc => 'Install thinking-sphinx for full text search', :type => :boolean, :default => false
      
      class_option :only, :desc => 'Install gems only these mentioned.', :type => :array, :default => []
      
      def install_gems_dependencies
        @selected_gems = options.only.empty? ? options.reject { |k,v| k == "only" || v == false }.keys : options.only
        @selected_gems.each do |gems|
          opt = ask("=> Would you like setup #{gems} gem? [yes]")
          if opt == "yes" || opt.blank?
            send("setup_#{gems}")
          end
        end        
      rescue Exception => e
        puts e.message
        puts "Please run `bundle install`, then re-run the generators."
      end

private
    
      def setup_mongoid
        add_gem("bson_ext")
        add_gem("mongoid")
        generate("mongoid:config")
      rescue Exception => e
        raise e
      end
      
      def setup_devise
         add_gem("devise")
         generate("devise:install")
         
         model_name = ask("Would you like the user model to be called? [user]")
         model_name = "user" if model_name.blank?
         generate("devise", model_name)

         print_notes("modify app/controllers/application_controller.rb")
         inject_into_file 'app/controllers/application_controller.rb', :after => "class ApplicationController < ActionController::Base" do
           "\n   before_filter :authenticate_user!"
         end 
      rescue Exception => e
        raise e
      end
      
      def setup_cancan
        add_gem("cancan")
        copy_file 'ability.rb', 'app/models/ability.rb'
        print_notes("modify app/controllers/application_controller.rb")
        inject_into_file 'app/controllers/application_controller.rb', :after => "class ApplicationController < ActionController::Base" do
          "\n   rescue_from CanCan::AccessDenied do |exception| flash[:alert] = exception.message; redirect_to root_url end;"
        end
      rescue Exception => e
        raise e
      end
       
      def setup_jquery_rails
        add_gem("jquery-rails")
        generate("jquery:install")
      rescue Exception => e
        raise e
      end
      
      def setup_simple_form
        add_gem("simple_form")
        generate("simple_form:install")
      rescue Exception => e
        raise e
      end
      
      def setup_carrierwave
        print_notes("carrierwave will use mini_magick by default (you can cofigure later)")
        add_gem("mini_magick")
        add_gem("carrierwave")
        copy_file 'image_uploader.rb', 'app/uploaders/image_uploader.rb'
        copy_file 'file_uploader.rb', 'app/uploaders/file_uploader.rb'
      rescue Exception => e
        raise e
      end
      
      def setup_kaminari
        add_gem("kaminari")
      rescue Exception => e
        raise e
      end
              
      def setup_ckeditor
        # remove the existing install (if any)
        destroy("public/javascripts/ckeditor")
        ver = ask("==> What version of CKEditor javascript files do you need? [default 3.5.4]")
        if ver == "3.5.4" || ver.blank?
          add_gem("ckeditor","3.5.4")
          template "ckeditor.rb", "config/initializers/ckeditor.rb"
          extract("setup/templates/ckeditor.tar.gz","public/javascripts","ckeditor")
        else
          add_gem("ckeditor",ver)
          generate("ckeditor:base --version=#{ver}")
        end
      rescue Exception => e
        raise e
      end
      
      def setup_meta_search
        add_gem("meta_search")
      rescue Exception => e
        raise e
      end
      
      def setup_faker
        add_gem("faker")
      rescue Exception => e
        raise e
      end
      
      def setup_thinking_sphinx
        print_notes("thinking-sphinx only works with MySQL / Postgresql")
        add_gem("thinking-sphinx")
      rescue Exception => e
        raise e
      end
      
    end
  end
end
