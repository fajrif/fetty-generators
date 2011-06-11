require 'generators/fetty'

module Fetty
  module Generators
    class SetupGenerator < Base #:nodoc: This generators will setup necessary gems to your app.
      
      class_option :mongoid, :desc => 'Install mongoid for replacing your ORM', :type => :boolean, :default => false
      class_option :devise, :desc => 'Install devise for authentication', :type => :boolean, :default => false 
      class_option :cancan, :desc => 'Install cancan for authorization', :type => :boolean, :default => true 
      class_option :jquery_rails, :desc => 'Install jquery-rails for javascript framework', :type => :boolean, :default => true
      class_option :simple_form, :desc => 'Install simple_form for generate form', :type => :boolean, :default => true
      class_option :carrierwave, :desc => 'Install carrierwave for handling file attachment', :type => :boolean, :default => true
      class_option :kaminari, :desc => 'Install kaminari for pagination', :type => :boolean, :default => true 
      class_option :ckeditor, :desc => 'Install ckeditor for WYSIWYG editor', :type => :boolean, :default => true
      class_option :meta_search, :desc => 'Install meta_search for ActiveRecord searching', :type => :boolean, :default => true
      class_option :faker, :desc => 'Install faker to help you populate data', :type => :boolean, :default => true
       
      def install_gems_dependencies
        begin
          options.each do |gems|
            if gems[1]
              opt = ask("=> Would you like install #{gems[0]} gem? [yes]")
              if opt == "yes" || opt.blank?
                send("setup_#{gems[0]}")
              end
            end
          end
          puts "**Please run 'bundle install'"
        rescue Exception => e
          puts e.message
        end     
      end

private
    
      def setup_mongoid
        begin
          add_gem("bson_ext")
          add_gem("mongoid")
          generate("mongoid:config")
        rescue Exception => e
          puts e.message
          install_gem("bson_ext")
          install_gem("mongoid")
          generate("mongoid:config")
        end
      end
      
      def setup_devise
        begin
          add_gem("devise")
      		generate("devise:install")
        rescue Exception => e
          puts e.message
          install_gem("devise")
      		generate("devise:install")
        end
        model_name = ask("Would you like the user model to be called? [user]")
  		  model_name = "user" if model_name.blank?
	  		generate("devise", model_name)
        
        puts "** modify app/controllers/application_controller.rb"
	  		inject_into_file 'app/controllers/application_controller.rb', :after => "class ApplicationController < ActionController::Base" do
			    "\n   before_filter :authenticate_user!"
			  end
      end
      
      def setup_cancan
        begin
          add_gem("cancan")
          copy_file 'ability.rb', 'app/models/ability.rb'
  		    puts "** modify app/controllers/application_controller.rb"
  		    inject_into_file 'app/controllers/application_controller.rb', :after => "class ApplicationController < ActionController::Base" do
    			  "\n   rescue_from CanCan::AccessDenied do |exception| flash[:alert] = exception.message; redirect_to root_url end;"
    		  end
        rescue Exception => e
          puts e.message
        end
      end
       
      def setup_jquery_rails
        begin
          add_gem("jquery-rails")
    			generate("jquery:install")
        rescue Exception => e
          puts e.message
          install_gem("jquery-rails")
    			generate("jquery:install")
        end
      end
      
      def setup_simple_form
        begin
          add_gem("simple_form")
    			generate("simple_form:install")
        rescue Exception => e
          puts e.message
          install_gem("simple_form")
    			generate("simple_form:install")
        end
      end
      
      def setup_carrierwave
        begin
          print_notes("carrierwave will use mini_magick by default (you can cofigure later)")
          add_gem("mini_magick")
          add_gem("carrierwave")
          copy_file 'file_uploader.rb', 'app/uploaders/file_uploader.rb'
        rescue Exception => e
          puts e.message
        end
      end
      
      def setup_kaminari
        begin
          add_gem("kaminari")
        rescue Exception => e
          puts e.message
        end
      end
      
      def setup_ckeditor
        begin
          # remove the existing install (if any)
          destroy("public/javascripts/ckeditor")
          ver = ask("==> What version of CKEditor javascript files do you need? [default 3.5.4]")
          if ver == "3.5.4" || ver.blank?
            add_gem("ckeditor","3.5.4")
            template "ckeditor.rb", "config/initializers/ckeditor.rb"
            extract("setup/templates/ckeditor.tar.gz","public/javascripts","ckeditor")
          else
            setup_gem("ckeditor",ver)
            generate("ckeditor:base --version=#{ver}")
          end
        rescue Exception => e
          puts e.message
        end
      end
      
      def setup_meta_search
        begin
        	add_gem("meta_search")
        rescue Exception => e
          puts e.message
        end
      end
      
      def setup_faker
        begin
          add_gem("faker")
        rescue Exception => e
          puts e.message
        end
      end
      
    end
  end
end