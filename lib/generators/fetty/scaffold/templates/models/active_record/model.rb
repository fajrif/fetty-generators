class <%= model_name %> < ActiveRecord::Base
  attr_accessible <%= model_attributes.map { |a| ":#{a.name}" }.join(", ") %>
  <%- if has_type? :image -%>
  mount_uploader <%= special_select(:image).map { |name| ":#{name}" }.join(", ") %>, ImageUploader
  <%- end -%>	
  <%- if has_type? :file -%>
  mount_uploader <%= special_select(:file).map { |name| ":#{name}" }.join(", ") %>, FileUploader
  <%- end -%>
  
  # define_index do
  #   indexes :title
  #   indexes :content
  # end
  
  
end
