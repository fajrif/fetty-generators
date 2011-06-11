require 'rails/generators/base'

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
        begin
          gemfile_content = File.read(destination_path("Gemfile"))
          File.open(destination_path("Gemfile"), 'a') { |f| f.write("\n") } unless gemfile_content =~ /\n\Z/
          gem name, options unless gemfile_content.include? name
        rescue Exception => e
          raise e
        end
      end
      
      def install_gem(name, options = {})
        begin
          print_notes("Installing #{name}")
          unless options.blank?
            run "gem install #{name} -v=#{options}"
          else
            run "gem install #{name}"
          end
        rescue Exception => e
          raise e
        end
      end
      
      # required to put generator path
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
          system("tar -C '#{destination_path(destinationpath)}' -xzvf '#{root_path(filepath)}' #{foldername}/")
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
      
    end
    
  end
end
