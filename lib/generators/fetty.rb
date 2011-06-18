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
        gemfile = File.expand_path(destination_path("Gemfile"), __FILE__) 
        begin
          gemfile_content = File.read(gemfile) 
          File.open(gemfile, 'a') { |f| f.write("\n") } unless gemfile_content =~ /\n\Z/
          gem name, options unless gemfile_content.include? name 
                
          if bundle_need_refresh?
            print_notes("Installing #{name}")
            ::Bundler.with_clean_env do
              unless options.empty?
                system("gem install #{name} -v=#{options}")
              else
                system("gem install #{name}")
              end
            end
          end        
        rescue Exception => e
          raise e  
        end if File.exist?(gemfile) 
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

      def destroy(path)
        begin
          if file_exists?(path)
            print_notes("Destroying #{path}")
            FileUtils.rm_r(destination_path(path), :force => true)
          end
        rescue Exception => e
          puts e.message
        end
      end

      def extract(filepath,destinationpath,foldername)
        begin
          print_notes("Extracting #{filepath}")
          system("tar -C '#{destination_path(destinationpath)}' -xzf '#{root_path(filepath)}' #{foldername}/")
        rescue Exception => e
          puts e.message
        end
      end

      def print_notes(notes)
        puts "*** NOTES : #{notes} ***" 
      end

      def print_usage
        self.class.help(Thor::Base.shell.new)
        exit
      end

      def refresh_bundle
        print_notes('Refresh bundle')
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
      
    end
  end
end
