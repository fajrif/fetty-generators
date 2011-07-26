require 'test_helper'

class <%= controller_name %>Test < ActionController::TestCase
<%- if action? :index -%>
  def test_index
    get :index
    assert_template 'index'
  end
<%- end -%>
<%- if action? :show -%>
  def test_show
    get :show, :id => <%= class_name %>.first
    assert_template 'show'
  end
<%- end -%>
<%- if action? :new -%>
  def test_new
    get :new
    assert_template 'new'
  end
<%- end -%>
<%- if action? :create -%>
  def test_create_invalid
    <%= class_name %>.any_instance.stub(:valid?).and_return(false)
    post :create
    assert_template 'new'
  end

  def test_create_valid
    <%= class_name %>.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to <%= generate_route_link(:action => :show, :suffix => 'url', :object => "assigns(:#{singular_name})" ) %>
  end
<%- end -%>
<%- if action? :edit -%>
  def test_edit
    get :edit, :id => <%= class_name %>.first
    assert_template 'edit'
  end
<%- end -%>
<%- if action? :update -%>
  def test_update_invalid
    <%= class_name %>.any_instance.stub(:valid?).and_return(false)
    put :update, :id => <%= class_name %>.first
    assert_template 'edit'
  end

  def test_update_valid
    <%= class_name %>.any_instance.stub(:valid?).and_return(true)
    put :update, :id => <%= class_name %>.first
    assert_redirected_to <%= generate_route_link(:action => :show, :suffix => 'url', :object => "assigns(:#{singular_name})" ) %>
  end
<%- end -%>
<%- if action? :destroy -%>
  def test_destroy
    <%= instance_name %> = <%= class_name %>.first
    delete :destroy, :id => <%= instance_name %>
    assert_redirected_to <%= generate_route_link(:action => :index, :suffix => 'url') %>
    assert !<%= class_name %>.exists?(<%= instance_name %>.id)
  end
<%- end -%>
end
