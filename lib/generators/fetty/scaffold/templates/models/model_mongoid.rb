class <%= class_name %>
  include Mongoid::Document	
  
  <%- for attribute in model_attributes -%>
  field :<%= attribute.name %>
  <%- end -%>

end