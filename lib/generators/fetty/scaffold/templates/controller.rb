class <%= plural_class_name %>Controller < ApplicationController
  <%- unless @tinymce_name.empty? -%>
  uses_tiny_mce(:options => { :theme => 'advanced', :theme_advanced_resizing => true, :theme_advanced_resize_horizontal => false, :plugins => %w{ table fullscreen }}, :only => [:new, :edit])
  <%- end -%>
  
  <%= controller_methods :actions %>
end
