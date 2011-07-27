class <%= class_name %> < ActiveRecord::Base
  <%= "set_table_name :#{table_name}\n" if table_name -%>
  <%- unless @paperclip_name.empty? -%>
  has_attached_file <%= @paperclip_name.map { |name| ":#{name}" }.join(", ") %>
  <%- end -%>	
  attr_accessible <%= model_attributes.map { |a| ":#{a.name}" }.join(", ") %>
end
