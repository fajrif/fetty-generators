require 'spec_helper'

describe <%= controller_name %> do
  describe 'routing' do
<%- if action? :index -%>
    it 'routes to #index' do
      get('/<%= plural_name %>').should route_to('<%= plural_name %>#index')
    end
<%- end -%>
<%- if action? :show -%>
    it 'routes to #show' do
      get('/<%= plural_name %>/1').should route_to('<%= plural_name %>#show', :id => '1')
    end
<%- end -%>
<%- if action? :new -%>
    it 'routes to #new' do
      get('/<%= plural_name %>/new').should route_to('<%= plural_name %>#new')
    end
<%- end -%>
<%- if action? :create -%>
    it 'routes to #create' do
      post('/<%= plural_name %>').should route_to('<%= plural_name %>#create')
    end
<%- end -%>
<%- if action? :edit -%>
    it 'routes to #edit' do
      get('/<%= plural_name %>/1/edit').should route_to('<%= plural_name %>#edit', :id => '1')
    end
<%- end -%>
<%- if action? :update -%>
    it 'routes to #update' do
      put('/<%= plural_name %>/1').should route_to('<%= plural_name %>#update', :id => '1')
    end
<%- end -%>
<%- if action? :destroy -%>
    it 'routes to #destroy' do
      delete('/<%= plural_name %>/1').should route_to('<%= plural_name %>#destroy', :id => '1')
    end
<%- end -%>
  end
end