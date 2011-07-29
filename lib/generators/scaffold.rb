module Fetty
  module Generators
    module Scaffold
      
      mattr_accessor :model_attributes, :controller_actions, :special_types
      
# setting variable & initialize mixins
      
      def self.included(base)
        self.model_attributes = []
        self.controller_actions = %w[index show new create edit update destroy]
        self.special_types = {} 
      end
      
      def setting_model_attributes
        attributes.each do |arg|
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
      
      def setting_controller_attributes
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
      
# public method generator 
      
      def generate_routes
        namespaces = plural_name.split('/')
        resource = namespaces.pop
        route namespaces.reverse.inject("resources :#{resource}") { |acc, namespace|
          "namespace :#{namespace} do #{acc} end"
        }
      rescue Exception => e
        raise e
      end
      
      def generate_action_links(action, authorize, object, link_text)
         out = ""
         out << "\t<% if can? :#{authorize}, #{object} %>\n\t" if using_cancan?
         
         link_path = generate_route_link(:action => action, :object => object, :suffix => 'path')
         
         unless action == :destroy
             out << "\t<%= link_to '#{link_text}', #{link_path} %>\n"
         else
             out << "\t<%= link_to '#{link_text}', #{link_path}, :confirm => 'Are you sure?', :method => :delete %>\n"
         end
         out << "\t<% end %>" if using_cancan?
         out.html_safe
      rescue Exception => e
        raise e
      end
      
      def generate_route_link(options ={})
        case options[:action]
        when :new
          "new_#{resource_name}_#{options[:suffix]}"
        when :edit
          "edit_#{resource_name}_#{options[:suffix]}(#{options[:object]})"
        when :index
          "#{resources_name}_#{options[:suffix]}"
        else
          "#{resource_name}_#{options[:suffix]}(#{options[:object]})"
        end
      rescue Exception => e
        raise e
      end
      
      def record_or_name_or_array
        unless has_namespace?
          instance_name('@')
        else
          namespace = singular_name.split('/')[0..-2]
          "[:#{namespace.join(', :')}, #{instance_name('@')}]"
        end
      rescue Exception => e
        raise e
      end
      
# public boolean function
      
      def has_namespace?
        scaffold_name.include?('::')
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
      
# playing with names
      
      def simple_name
        class_name.underscore.humanize.downcase
      end
      
      def class_name
        scaffold_name.split('::').last.camelize.singularize
      end
      
      def table_name
        scaffold_name.split('::').last.pluralize.downcase
      end
      
      def singular_name
        scaffold_name.underscore.singularize
      end
      
      def plural_name
        singular_name.pluralize
      end
      
      def instance_name(suffix = '')
        suffix += singular_name.split('/').last
      end
      
      def instances_name(suffix = '')
        instance_name(suffix).pluralize
      end
      
      def resource_name
        scaffold_name.underscore.gsub('/','_').singularize
      end
      
      def resources_name
        resource_name.pluralize
      end
      
      def model_name(opt = :name)
        case opt
        when :name
          class_name
        when :path
          "app/models/#{class_name.downcase}.rb"
        end
      end
      
      def migration_name(opt = :name)
        case opt
        when :name
          plural_name.camelize.delete('::').insert(0,'Create')
        when :path
          "db/migrate/create_#{plural_name.gsub('/', '_')}.rb"
        end
      end
      
      def controller_name(opt = :name)
        case opt
        when :name
          plural_name.camelize.insert(-1,'Controller')
        when :path
          "app/controllers/#{plural_name}_controller.rb"
        end
      end
      
      def helper_name(opt = :name)
        case opt
        when :name
          plural_name.camelize.insert(-1,'Helper')
        when :path
          "app/helpers/#{plural_name}_helper.rb"
        end
      end
      
    end
  end
end
