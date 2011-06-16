require 'generators/fetty'
require 'generators/scaffold'
require 'rails/generators/migration'
require 'rails/generators/generated_attribute'

module Fetty
  module Generators
    class ScaffoldGenerator < Base
      include Rails::Generators::Migration
      include Fetty::Generators::Scaffold
            
      argument :scaffold_name, :type => :string, :required => true, :banner => 'ModelName'
      argument :attributes, :type => :array, :default => [], :banner => 'attribute:type'
                        
      class_option :controller, :desc => 'Generate controller, helper, or views.', :type => :boolean, :default => true
      class_option :model, :desc => "Generate a model or migration file.", :type => :boolean, :default => true
      class_option :migration, :desc => "Generate migration file for model.", :type => :boolean, :default => true
      class_option :timestamps, :desc => "Add timestamps to migration file.", :type => :boolean, :default => true
      class_option :test, :desc => "Generate Test files, default is using test:unit", :type => :boolean, :default => true

      class_option :except, :desc => 'Generate all controller actions except these mentioned.', :type => :array, :default => []
      
      def generate_scaffold
        
          begin
            print_usage unless scaffold_name.underscore =~ /^[a-z][a-z0-9_\/]+$/ && !attributes.empty?
            print_usage unless attributes.drop_while { |arg| arg.include?(':') }.count == 0
                  
            setting_model_attributes
            if options[:model]
               generate_model
               if options.migration?
                  generate_migration
                end
            end
                
            if options.controller?
               setting_controller_attributes
               generate_controller
               generate_helper
               generate_views
               generate_routes
            end
                
            if options.test?
              generate_test
            end                  
          rescue Exception => e
           puts e.message
          end
      end

private 

      def generate_model
        begin
          template 'models/active_record/model.rb', model_name(:path)
        rescue Exception => e
          raise e
        end
      end
      
      def generate_migration
        begin
          migration_template 'models/active_record/migration.rb', migration_name(:path)
        rescue Exception => e
          raise e
        end
      end
      
      def generate_controller
        begin
          template 'controllers/active_record/controller.rb', controller_name(:path)
        rescue Exception => e
          raise e
        end
      end
                
      def generate_helper
        begin
          template 'helpers/helper.rb', helper_name(:path)
        rescue Exception => e
          raise e
        end
      end
                
      def generate_views
        begin
          controller_actions.each do |action|
            unless action == 'create' || action == 'update' || action == 'destroy'
              template "views/#{action}.html.erb", "app/views/#{plural_name}/#{action}.html.erb"
              if action == 'index'
                template "views/index.js.erb", "app/views/#{plural_name}/index.js.erb"
                template "views/_table.html.erb", "app/views/#{plural_name}/_table.html.erb"
              end
            end
          end
             
          if actions? :new, :edit
            template "views/_form.html.erb", "app/views/#{plural_name}/_form.html.erb"
          end
        rescue Exception => e
          raise e
        end
      end
          
      def generate_test
        # begin
        #   if test_framework == :rspec
        #     template "tests/#{test_framework}/controller.rb", "spec/controllers/#{plural_name}_controller_spec.rb"
        #   else
        #     template "tests/#{test_framework}/controller.rb", "test/functional/#{plural_name}_controller_test.rb"
        #   end
        #   
        #   if test_framework == :rspec
        #     template "tests/rspec/model.rb", "spec/models/#{model_path}_spec.rb"
        #     template 'fixtures.yml', "spec/fixtures/#{model_path.pluralize}.yml"
        #   else
        #     template "tests/#{test_framework}/model.rb", "test/unit/#{model_path}_test.rb"
        #     template 'fixtures.yml', "test/fixtures/#{model_path.pluralize}.yml"
        #   end
        #   
        # rescue Exception => e
        #   raise e
        # end
      end
      
      
      # FIXME: Should be proxied to ActiveRecord::Generators::Base
      # Implement the required interface for Rails::Generators::Migration.
      def self.next_migration_number(dirname) #:nodoc:
        ActiveRecord::Generators::Base.next_migration_number(dirname)
      end      
    end
  end
end
