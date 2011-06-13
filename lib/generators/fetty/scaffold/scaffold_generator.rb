require 'generators/fetty'
require 'generators/scaffold'

module Fetty
  module Generators
    class ScaffoldGenerator < Base
      include Fetty::Generators::Scaffold
      
      attr_accessor :scaffold_name, :model_attributes, :controller_actions
      
      argument :scaffold_name, :type => :string, :required => true, :banner => 'ModelName'
      argument :arguments, :type => :array, :default => [], :required => true, :banner => 'model:attributes'
            
      class_option :controllers, :desc => 'Generate controller, helper, or views.', :type => :boolean, :default => true
      class_option :models, :desc => "Generate a model or migration file.", :type => :boolean, :default => true
      class_option :migrations, :desc => "Generate migration file for model.", :type => :boolean, :default => true
      class_option :timestamps, :desc => "Add timestamps to migration file.", :type => :boolean, :default => true
      class_option :test, :desc => "Generate Test files, default is using test:unit", :type => :boolean, :default => true
      
      class_option :except, :desc => 'Generate all controller actions except these mentioned.', :type => :array, :default => []
            
      def initialize     
       begin
         print_usage unless scaffold_name.underscore =~ /^[a-z][a-z0-9_\/]+$/
         
         setting_model_attributes
         
         if options.models?
            generate_model
            if options.migrations?
               generate_migration
             end
         end
             
         if options.controllers?
            setting_controller_attributes
            generate_controller
            generate_helper
            generate_view
            setting_route
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
          template 'models/active_record_model.rb', "app/models/#{model_path}.rb"
        rescue Exception => e
          raise e
        end
      end

      def generate_migration
        begin
          migration_template 'active_record_migration.rb', "db/migrate/create_#{model_path.pluralize.gsub('/', '_')}.rb"
        rescue Exception => e
          raise e
        end
      end

      def generate_controller
        begin
          template 'controllers/controller.rb', "app/controllers/#{plural_name}_controller.rb"
        rescue Exception => e
          raise e
        end
      end

      def generate_view
        begin
          controller_actions.each do |action|
            if %w[index show new edit].include?(action) # Actions with templates
              template "views/#{action}.html.erb", "app/views/#{plural_name}/#{action}.html.erb"
              if action == 'index'
                template "views/_table.html.erb", "app/views/#{plural_name}/_table.html.erb"
                template "views/index.js.erb", "app/views/#{plural_name}/index.js.erb"
              end 
            end
          end

          if form_partial?
            template "views/_form.html.erb", "app/views/#{plural_name}/_form.html.erb"
          end
        rescue Exception => e
          raise e
        end
      end
      
      def generate_helper
        begin
          template 'helper.rb', "app/helpers/#{plural_name}_helper.rb"
        rescue Exception => e
          raise e
        end
      end

      
      
      def generate_test
        begin
          if test_framework == :rspec
            template "tests/#{test_framework}/controller.rb", "spec/controllers/#{plural_name}_controller_spec.rb"
          else
            template "tests/#{test_framework}/controller.rb", "test/functional/#{plural_name}_controller_test.rb"
          end
          
          if test_framework == :rspec
            template "tests/rspec/model.rb", "spec/models/#{model_path}_spec.rb"
            template 'fixtures.yml', "spec/fixtures/#{model_path.pluralize}.yml"
          else
            template "tests/#{test_framework}/model.rb", "test/unit/#{model_path}_test.rb"
            template 'fixtures.yml', "test/fixtures/#{model_path.pluralize}.yml"
          end
          
        rescue Exception => e
          raise e
        end
      end
               
    end
  end
end
