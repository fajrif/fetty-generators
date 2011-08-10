require 'rubygems'
require 'rubygems/command.rb'
require 'rubygems/dependency_installer.rb'
require 'rails/generators/base'
require 'bundler'

module Fetty
  module Generators
    class Base < Rails::Generators::Base #:nodoc:
      
      def self.source_root
        @_fetty_source_root = File.expand_path(File.join(File.dirname(__FILE__), 'fetty', generator_name, 'templates'))
      end
      
      def self.banner
        "rails generate fetty:#{generator_name} #{self.arguments.map{ |a| a.usage }.join(' ')} [options]"
      end
      
protected
      
      def add_gem(name, options = {})
        unless gemfile_included? name 
          gemfile = File.expand_path(destination_path("Gemfile"), __FILE__)
          gemfile_content = File.read(gemfile)
          File.open(gemfile, 'a') { |f| f.write("\n") } unless gemfile_content =~ /\n\Z/
          
          gem name, options
          
          if bundle_need_refresh?
            refresh_bundle(false)
          end
        end
      rescue Exception => e
        raise e
      end
      
      def gemfile_included?(name)
        file_contains?("Gemfile",name)
      rescue Exception => e
        raise e
      end
      
      def root_path(path)
        File.expand_path(File.join(File.dirname(__FILE__), 'fetty', path))
      end
      
      def destination_path(path)
        File.join(destination_root, path)
      end  
      
      def file_exists?(path)
        File.exist? destination_path(path)
      end
      
      def folder_exists?(path)
        File.directory? path
      end
      
      def destroy(path)
        begin
          if file_exists?(path)
            print_notes("Destroying #{path}")
            FileUtils.rm_r(destination_path(path), :force => true)
          end
        rescue Exception => e
          raise e
        end
      end
      
      def extract(filepath,destinationpath,foldername)
        begin
          print_notes("Extracting #{filepath}")
          system("tar -C '#{destination_path(destinationpath)}' -xzf '#{root_path(filepath)}' #{foldername}/")
        rescue Exception => e
          raise e
        end
      end
      
      def asking(messages,&block)
        opt = ask("=> #{messages} [yes]")
        if opt == "yes" || opt.blank?
          yield
        end
      rescue Exception => e
        raise e
      end
      
      def print_notes(message,notes = "notes",color = :yellow)
        puts        '', '='*80
        say_status  "#{notes}", "#{message}", color
        puts        '='*80, ''; sleep 0.5
      end
      
      def print_usage
        self.class.help(Thor::Base.shell.new)
        exit
      end
      
      def install_gem(name,version = "")
        print_notes("Installing #{name}")
        ::Bundler.with_clean_env do
          if version.blank?
            system("gem install #{name}")
          else
            system("gem install #{name} -v=#{version}")
          end
        end
      rescue Exception => e
        raise e
      end
      
      def refresh_bundle(verbose = true)
        print_notes('Refresh bundle') if verbose
        ::Bundler.with_clean_env do
         `bundle install`
        end
      rescue Exception => e
        raise e
      end
      
      def bundle_need_refresh?
        ::Bundler.with_clean_env do
          `bundle check`
        end
        $? == 0 ? false : true
      rescue Exception => e
        raise e
      end
      
      def file_contains?(filename,check_string)
        file = File.expand_path(destination_path(filename), __FILE__)
        if File.exist?(file)
          file_content = File.read(file)
          file_content.include?(check_string) ? true : false
        else
          false
        end
      rescue Exception => e
        raise e 
      end
      
      def must_load_lib_directory
        unless file_contains?("config/application.rb",'config.autoload_paths += %W(#{config.root}/lib)')
          inject_into_file "config/application.rb", :after => "Rails::Application" do
            "\n\t\t" + 'config.autoload_paths += %W(#{config.root}/lib)'
          end
        end
      rescue Exception => e
        raise e
      end
      
      def using_cancan?
        gemfile_included?("cancan") && file_exists?("app/models/ability.rb")
      rescue Exception => e
        raise e
      end
      
      def using_mongoid?
        gemfile_included?("mongoid") && file_exists?("config/mongoid.yml")
      rescue Exception => e
        raise e
      end
      
      def using_test_unit?
        folder_exists?("tests")
      rescue Exception => e
        raise e
      end
      
      def using_rspec?
        gemfile_included?("rspec") && folder_exists?("spec")
      rescue Exception => e
        raise e
      end
      
      def using_fetty_authentication?
        file_exists?("app/controllers/users_controller.rb") &&
        file_exists?("app/controllers/sessions_controller.rb") &&
        file_exists?("app/controllers/reset_passwords_controller.rb") &&
        file_exists?("lib/users_authentication.rb")
      rescue Exception => e
        raise e
      end
      
      
    end
  end
end
