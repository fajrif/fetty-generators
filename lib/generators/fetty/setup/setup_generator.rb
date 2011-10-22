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
      class_option :test, :desc => 'Setup all test framework rspec / cucumber, capybara, guard, etc.', :type => :boolean, :default => true
      
      # optional
      class_option :mongoid, :desc => 'Install mongoid for replacing your ORM', :type => :boolean, :default => false
      class_option :only, :desc => 'Install gems only these mentioned.', :type => :array, :default => []
      
      def install_gems_dependencies
        asking "Would you like to setup mongoid gem?" do
          setup_mongoid
        end if options['mongoid']
        @selected_gems = options.only.empty? ? options.reject { |k,v| k == "only" || k == "mongoid" || v == false }.keys : options.only
        @selected_gems.each do |gems|
          asking "Would you like to setup #{gems} gem?" do
            send("setup_#{gems.gsub('-','_')}")
          end
        end
        if options.only.empty?
          print_notes("Refreshing Bundle")
          refresh_bundle
        end
      rescue Exception => e
        print_notes(e.message,"error",:red)
      end
      
private
      
      def setup_mongoid
        gem "bson_ext"
        gem "mongoid"
        generate("mongoid:config")
        set_application_config { "  config.mongoid.preload_models = true\n" }
      rescue Exception => e
        raise e
      end
      
      def setup_cancan
        gem "cancan"
        copy_file 'ability.rb', 'app/models/ability.rb'
        inject_into_class 'app/controllers/application_controller.rb', ApplicationController do
          "  rescue_from CanCan::AccessDenied do |exception| flash[:alert] = exception.message; redirect_to root_url end;\n"
        end
      rescue Exception => e
        raise e
      end
      
      def setup_jquery_rails
        gem "jquery-rails"
        generate("jquery:install") unless rails_3_1?
      rescue Exception => e
        raise e
      end
      
      def setup_simple_form
        gem "simple_form"
        generate("simple_form:install")
      rescue Exception => e
        raise e
      end
      
      def setup_carrierwave
        gem "mini_magick"
        gem "carrierwave"
        copy_file 'image_uploader.rb', 'app/uploaders/image_uploader.rb'
        copy_file 'file_uploader.rb', 'app/uploaders/file_uploader.rb'
        print_notes("carrierwave will use mini_magick by default!")
      rescue Exception => e
        raise e
      end
      
      def setup_kaminari
        gem "kaminari"
      rescue Exception => e
        raise e
      end
      
      def setup_ckeditor
        ver = ask("==> What version of CKEditor javascript files do you need? [default 3.5.4]")
        if ver == "3.5.4" || ver.blank?
          gem "ckeditor", "3.5.4"
          template "ckeditor.rb", "config/initializers/ckeditor.rb"
          unless rails_3_1?
            # remove the existing install (if any)
            remove_file("public/javascripts/ckeditor")
            extract("setup/templates/ckeditor.tar.gz","public/javascripts","ckeditor")
          else
            remove_file("vendor/assets/javascripts/ckeditor")
            `mkdir vendor/assets/javascripts` unless Dir.exists? "vendor/assets/javascripts"
            extract("setup/templates/ckeditor.tar.gz","vendor/assets/javascripts","ckeditor")
          end
        else
          gem "ckeditor", ver
          generate("ckeditor:base --version=#{ver}")
        end
      rescue Exception => e
        raise e
      end
      
      def setup_test
        gem_group :development, :test do
          gem "spork", "> 0.9.0.rc"
          gem "guard-spork"
          gem 'rspec-rails'
          gem 'guard-rspec'
          gem 'capybara'
          gem 'factory_girl_rails'
          gem 'faker'
          gem 'database_cleaner'
          gem 'escape_utils'
          if RUBY_PLATFORM =~ /darwin/i
            gem 'rb-fsevent', :require => false
            gem 'growl'
          end
        end
        
        # remove the existing Guardfile (if any)
        remove_file("Guardfile")
        
        `guard init`
        `guard init spork`
        copy_file 'escape_utils.rb', 'config/initializers/escape_utils.rb'
        remove_file("spec")
        generate("rspec:install")
        remove_file 'spec/spec_helper.rb'
        template 'spec_helper.rb', 'spec/spec_helper.rb', :force => true
        `guard init rspec`
        
        asking "Would you like to install Cucumber?" do
          remove_file("features")
          gem "cucumber-rails", :group => [:development, :test]
          gem "guard-cucumber", :group => [:development, :test]
          generate("cucumber:install", "--rspec", "--capybara")
          template 'env.rb', 'features/support/env.rb', :force => true
          `guard init cucumber`
        end
        
        # custom modify cli
        inject_into_file "Guardfile", :after => /guard 'rspec', :version => 2/ do
          " , :cli => '--drb'"
        end if file_exists? "Guardfile"
        
        print_notes("Please make sure you already install growl with growlnotify!!")
      rescue Exception => e
        raise e 
      end
      
    end
  end
end
