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
      
      # need to be checked      
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
              
      def generate_action_links(action, object, link_text, link_path)
         out = ""
         out << "\t<% if can? :#{action}, #{object} %>\n"
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
        if scaffold_name.include?('::')
          plural_name.gsub('/', '_')
        end
      end
      
      def class_name
        if scaffold_name.include?('::')
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
        if scaffold_name.include?('::')
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
        if action? :show
          name = options[:instance_variable] ? "@#{instance_name}" : instance_name
          if %w(new edit).include? options[:action].to_s
            "#{options[:action].to_s}_#{item_resource}_path(#{name})"
          else
            if scaffold_name.include?('::')
              namespace = singular_name.split('/')[0..-2]
              "[ :#{namespace.join(', :')}, #{name} ]"
            else
              name
            end
          end
        else
          items_path
        end
      end
      
      def item_url
        if action? :show
          item_resource + '_url'
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
            

      # def controller_methods(dir_name)
      #   controller_actions.map do |action|
      #     read_template("#{dir_name}/#{action}.rb")
      #   end.join("\n").strip
      # end
      # 
      # 
      # def model_columns_for_attributes
      #   class_name.constantize.columns.reject do |column|
      #     column.name.to_s =~ /^(id|created_at|updated_at)$/
      #   end
      # end
      # 
      # def read_template(relative_path)
      #   ERB.new(File.read(find_in_source_paths(relative_path)), nil, '-').result(binding)
      # end
      
    end
  end
end
