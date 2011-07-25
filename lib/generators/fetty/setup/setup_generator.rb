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
      
      # optional
      class_option :mongoid, :desc => 'Install mongoid for replacing your ORM', :type => :boolean, :default => false
      class_option :thinking_sphinx, :desc => 'Install thinking-sphinx for full text search', :type => :boolean, :default => false
      class_option :test, :desc => 'Setup all test framework rspec, cucumber, webrat, guard', :type => :boolean, :default => false
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
        puts "Please run `bundle install`, then run again `rails g fetty:setup`"
      end

private
      
      def setup_mongoid
        add_gem("bson_ext")
        add_gem("mongoid")
        generate("mongoid:config")
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
      
      def setup_thinking_sphinx
        print_notes("thinking-sphinx only works with MySQL / Postgresql")
        add_gem("thinking-sphinx")
      rescue Exception => e
        raise e
      end
      
      def setup_test
        print_notes("Install test framework for TDD/BDD")
        
        gemfile = File.expand_path(destination_path("Gemfile"), __FILE__)
        
        group_gems =  "\n group :development, :test do"
        group_gems << "\n   gem 'rspec-rails'"
        group_gems << "\n   gem 'capybara'"
        group_gems << "\n   gem 'faker'"
        group_gems << "\n   gem 'database_cleaner'"
        group_gems << "\n   gem 'escape_utils'"
        group_gems << "\n   gem 'guard-rspec'"
        group_gems << "\n   if RUBY_PLATFORM =~ /darwin/i"
        group_gems << "\n       gem 'rb-fsevent', :require => false"
        group_gems << "\n       gem 'growl'"
        group_gems << "\n   end"
        group_gems << "\n end\n"
        
        File.open(gemfile, 'a') { |f| f.write(group_gems) }
        refresh_bundle
        copy_file 'escape_utils.rb', 'config/initializers/escape_utils.rb'
        
        generate("rspec:install")
        copy_file 'spec_helper.rb', 'spec/spec_helper.rb'
        `guard init rspec`
        
        opt = ask("=> Would you like to install Cucumber? [yes]")
        if opt == "yes" || opt.blank?
          add_gem("cucumber-rails", group => [:development, :test])
          add_gem("guard-cucumber", group => [:development, :test])
          generate("cucumber:install", "--rspec", "--capybara")
          `guard init cucumber`
        end
        
        print_notes("Please make sure you already install growl and growlnotify!!")
        print_notes("Please edit spec_helper.rb / env.rb\nFor some databases (like MongoDB and CouchDB) you may need to use :truncation instead.")
        
      rescue Exception => e
        raise e 
      end
      
    end
  end
end
