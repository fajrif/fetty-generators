class <%= class_name %> < ActiveRecord::Base
  <%= "set_table_name :#{table_name}\n" if table_name -%>
  <%- unless @carrierwave_name.empty? -%>
  mount_uploader <%= @carrierwave_name.map { |name| ":#{name}" }.join(", ") %>, ImageUploader
  <%- end -%>	
  attr_accessible <%= model_attributes.map { |a| ":#{a.name}" }.join(", ") %>
end
