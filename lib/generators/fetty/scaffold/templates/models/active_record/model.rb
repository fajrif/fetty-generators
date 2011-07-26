class <%= model_name %> < ActiveRecord::Base
  attr_accessible <%= model_attributes.map { |a| ":#{a.name}" }.join(", ") %>
  <%- if has_type? :image -%>
  mount_uploader <%= special_select(:image).map { |name| ":#{name}" }.join(", ") %>, ImageUploader
  <%- end -%>	
  <%- if has_type? :file -%>
  mount_uploader <%= special_select(:file).map { |name| ":#{name}" }.join(", ") %>, FileUploader
  <%- end -%>
  
  define_index do
  <%- model_attributes.each do |a| -%>
    <%- if a.type == :string || a.type == :text -%>
    indexes :<%= a.name %>, :sortable => true
    <%- end -%>
  <%- end -%>
    
    has :created_at
    set_property :enable_star => 1
    set_property :min_prefix_len => 1
  end
  
end
