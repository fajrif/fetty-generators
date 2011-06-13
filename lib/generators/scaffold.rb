
module Fetty
  module Generators
    module Scaffold
      
      # setting methods
      def setting_model_attributes
        begin
          @model_attributes = []
           arguments.each do |arg|
              if arg.include?(':')
                if arg.include?(':file') || arg.include?(':image')
                  if arg.include?(':file')
                    @file_attributes ||= []
                    @file_attributes << arg.split(':').first
                  else
                    @image_attributes ||= []
                    @image_attributes << arg.split(':').first
                  end
                  @model_attributes << Rails::Generators::GeneratedAttribute.new(arg.split(':').first, "string")
                elsif arg.include?(':editor')
                  @editor_attributes ||= []
                  @editor_attributes << arg.split(':').first
                  @model_attributes << Rails::Generators::GeneratedAttribute.new(arg.split(':').first, "text")
                else
                  @model_attributes << Rails::Generators::GeneratedAttribute.new(*arg.split(':'))
                end
              end
            end
            @model_attributes.uniq!
        rescue Exception => e
          raise e
        end
      end
      
      def setting_controller_attributes
        begin
          @controller_actions = %w[index show new create edit update destroy]
            unless options.except.empty?
              options.except.each do |action|
                @controller_actions.delete(action)
                if action == 'new'
                  @controller_actions.delete("create")
                elsif action == 'edit'
                  @controller_actions.delete("update")
                end
              end
            end
            @controller_actions.uniq!
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
      
      
      # def form_partial?
      #   actions? :new, :edit
      # end
      # 
      # def render_form
      #   if form_partial?
      #     "<%= render 'form' %>"
      #   else
      #     read_template("views/_form.html.erb")
      #   end
      # end
      # 
      # def all_actions
      #   %w[index show new create edit update destroy]
      # end
      # 
      # def action?(name)
      #   controller_actions.include? name.to_s
      # end
      # 
      # def actions?(*names)
      #   names.all? { |name| action? name }
      # end
      # 
      # def singular_table_name
      #   scaffold_name.pluralize.singularize
      # end
      # 
      # def singular_name
      #   scaffold_name.underscore
      # end
      # 
      # def plural_name
      #   scaffold_name.underscore.pluralize
      # end
      # 
      # def table_name
      #   if scaffold_name.include?('::')
      #     plural_name.gsub('/', '_')
      #   end
      # end
      # 
      # def class_name
      #   if scaffold_name.include?('::')
      #     scaffold_name.camelize
      #   else
      #     scaffold_name.split('::').last.camelize
      #   end
      # end
      # 
      # def model_path
      #   class_name.underscore
      # end
      # 
      # def plural_class_name
      #   plural_name.camelize
      # end
      # 
      # def instance_name
      #   if scaffold_name.include?('::')
      #     singular_name.gsub('/','_')
      #   else
      #     singular_name.split('/').last
      #   end
      # end
      # 
      # def instances_name
      #   instance_name.pluralize
      # end
      # 
      # def controller_methods(dir_name)
      #   controller_actions.map do |action|
      #     read_template("#{dir_name}/#{action}.rb")
      #   end.join("\n").strip
      # end
      # 
      # def item_resource
      #   scaffold_name.underscore.gsub('/','_')
      # end
      # 
      # def items_path
      #   if action? :index
      #     "#{item_resource.pluralize}_path"
      #   else
      #     "root_path"
      #   end
      # end
      # 
      # def item_path(options = {})
      #   if action? :show
      #     name = options[:instance_variable] ? "@#{instance_name}" : instance_name
      #     if %w(new edit).include? options[:action].to_s
      #       "#{options[:action].to_s}_#{item_resource}_path(#{name})"
      #     else
      #       if scaffold_name.include?('::') && !@namespace_model
      #         namespace = singular_name.split('/')[0..-2]
      #         "[ :#{namespace.join(', :')}, #{name} ]"
      #       else
      #         name
      #       end
      #     end
      #   else
      #     items_path
      #   end
      # end
      # 
      # def item_url
      #   if action? :show
      #     item_resource + '_url'
      #   else
      #     items_url
      #   end
      # end
      # 
      # def items_url
      #   if action? :index
      #     item_resource.pluralize + '_url'
      #   else
      #     "root_url"
      #   end
      # end
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
