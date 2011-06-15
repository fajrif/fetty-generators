module Fetty
  module Generators
    module Scaffold

      mattr_accessor :model_attributes, :controller_actions, :special_types
      
      def self.included(base)
        self.model_attributes = []
        self.controller_actions = %w[index show new create edit update destroy]
        self.special_types = {} 
      end
      
      def setting_model_attributes
        begin
           arguments.each do |arg|
              if arg.include?(':')
                if arg.include?(':file') || arg.include?(':image') || arg.include?(':editor')
                  self.special_types[arg.split(':').first] = arg.split(':').last.to_sym
                  if arg.include?(':editor')
                    self.model_attributes << Rails::Generators::GeneratedAttribute.new(arg.split(':').first, "text")
                  else
                    self.model_attributes << Rails::Generators::GeneratedAttribute.new(arg.split(':').first, "string")
                  end  
                else
                  self.model_attributes << Rails::Generators::GeneratedAttribute.new(*arg.split(':'))
                end
              end
            end
            self.model_attributes.uniq!
        rescue Exception => e
          raise e
        end
      end
      
      def setting_controller_attributes
        begin
            unless options.except.empty?
              options.except.each do |action|
                self.controller_actions.delete(action)
                if action == 'new'
                  self.controller_actions.delete(:create)
                elsif action == 'edit'
                  self.controller_actions.delete(:update)
                end
              end
            end
            self.controller_actions.uniq!
        rescue Exception => e
          raise e
        end
      end
      
      def setting_routes
        begin
          namespaces = plural_name.split('/')
          resource = namespaces.pop
          route namespaces.reverse.inject("resources :#{resource}") { |acc, namespace|
            "namespace(:#{namespace}){ #{acc} }"
          }
        rescue Exception => e
          raise e
        end
      end
              
      def generate_action_links(action, authorize, object, link_text)
         out = ""
         out << "\t<% if can? :#{authorize}, #{object} %>\n"
         
         if object.start_with?('@')
            link_path = item_path(:action => action, :instance_variable => true)
         else
            link_path = item_path(:action => action)
         end
        
         unless action == :destroy
             out << "\t\t<%= link_to '#{link_text}', #{link_path} %>\n"
         else
             out << "\t\t<%= link_to '#{link_text}', #{link_path}, :confirm => 'Are you sure?', :method => :delete %>\n"
         end
         out << "\t<% end %>"
         out.html_safe
      end
      
      def has_type?(type)
        self.special_types.has_value? type
      end
      
      def special_select(type)
        self.special_types.select { |k,v| v == type }.keys
      end
    
      def action?(name)
        self.controller_actions.include? name.to_s
      end
      
      def actions?(*names)
        names.all? { |name| action? name }
      end
      
      def controller_actions?(*names)
        names.all? { |name| action? name }
      end      

      def singular_table_name
        scaffold_name.pluralize.singularize
      end
      
      def singular_name
        scaffold_name.underscore
      end
      
      def plural_name
        scaffold_name.underscore.pluralize
      end
      
      def table_name
        if scaffold_name.include?('::') && @namespace_model
          plural_name.gsub('/', '_')
        end
      end
      
      def class_name
        if @namespace_model
          scaffold_name.camelize
        else
          scaffold_name.split('::').last.camelize
        end
      end
      
      def model_path
        class_name.underscore
      end
      
      def plural_class_name
        plural_name.camelize
      end
      
      def instance_name
        if @namespace_model
          singular_name.gsub('/','_')
        else
          singular_name.split('/').last
        end
      end
      
      def instances_name
        instance_name.pluralize
      end
      
      def item_resource
        scaffold_name.underscore.gsub('/','_')
      end
      
      def items_path
        if action? :index
          "#{item_resource.pluralize}_path"
        else
          "root_path"
        end
      end
      
      def item_path(options = {})
        name = options[:instance_variable] ? "@#{instance_name}" : instance_name
        suffix = options[:full_url] ? "url" : "path"
        
        if options[:action] == :index
          items_path
        elsif options[:action] == :new
          "new_#{item_resource}_#{suffix}"
        elsif options[:action] == :edit
          "edit_#{item_resource}_#{suffix}(#{name})"
        else
          if scaffold_name.include?('::') && !@namespace_model
            namespace = singular_name.split('/')[0..-2]
            "[:#{namespace.join(', :')}, #{name}]"
          else
            name
          end
        end
      end
      
      def item_url
        if action? :show
          item_path(:full_url => true, :instance_variable => true)
        else
          items_url
        end
      end
            
      def items_url
        if action? :index
          item_resource.pluralize + '_url'
        else
          "root_url"
        end
      end
      
      def item_path_for_spec(suffix = 'path')
        if action? :show
          "#{item_resource}_#{suffix}(assigns[:#{instance_name}])"
        else
          if suffix == 'path'
            items_path
          else
            items_url
          end
        end
      end

      def item_path_for_test(suffix = 'path')
        if action? :show
          "#{item_resource}_#{suffix}(assigns(:#{instance_name}))"
        else
          if suffix == 'path'
            items_path
          else
            items_url
          end
        end
      end
      
                  
    end
  end
end
