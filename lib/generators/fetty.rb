require 'rails/generators/base'
require 'bundler'
require 'bundler/dsl'

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
      
      def add_gem(&block)
        yield
        refresh_bundle
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
      
      def class_exists?(class_name)
        klass = Rails.application.class.parent_name.constantize.const_get(class_name)
        return klass.is_a?(Class)
      rescue NameError
        return false
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
        unless message.blank?
          puts        '', '='*80
          say_status  "#{notes}", "#{message}", color
          puts        '='*80, ''; sleep 0.5
        else
          puts "\n"
        end
      end
      
      def print_usage
        self.class.help(Thor::Base.shell.new)
        exit
      end
      
      def install_local_gem(name,version = nil)
        ::Bundler.with_clean_env do
          if version
            `gem install #{name} -v=#{version}`
          else
            `gem install #{name}`
          end
        end
        $? == 0 ? true : false
      rescue Exception => e
        raise e
      end
      
      def check_local_gem?(name,version = nil)
        ::Bundler.with_clean_env do
          if version
            `gem list #{name} -i -v=#{version}`
          else
            `gem list #{name} -i`
          end
        end
        $? == 0 ? true : false
      rescue Exception => e
        raise e
      end
      
      def refresh_bundle
        ::Bundler.with_clean_env do
          `bundle`
        end
      rescue Exception => e
        raise e
      end
      
      def set_application_config(&block)
        inject_into_class "config/application.rb", "Application" do
          yield
        end
      rescue Exception => e
        raise e
      end
      
      def must_load_lib_directory
        set_application_config do
          '  config.autoload_paths += %W(#{config.root}/lib)' + "\n"
        end
      end
      
      def gemfile_included?(name)
        ::Bundler.with_clean_env do
          `bundle show #{name}`
        end
        $?.exitstatus == 0 ? true : false
      rescue Exception => e
        raise e
      end
      
      def using_cancan?
        gemfile_included?("cancan") && class_exists?("Ability")
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
        class_exists?("UsersController") &&
        class_exists?("SessionsController") &&
        class_exists?("ResetPasswordsController") &&
        class_exists?("User")
      rescue Exception => e
        raise e
      end
      
      def check_required_gems?(*names)
        names.each do |name|
          return false unless gemfile_included? name
        end
        true
      rescue Exception => e
        raise e
      end
      
    end
  end
end

