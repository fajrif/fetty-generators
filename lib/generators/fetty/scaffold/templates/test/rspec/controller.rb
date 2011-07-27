require 'spec_helper'

describe <%= controller_name %> do
<% if action? :index %>
  describe "GET index" do
    it "should render index template" do
      stub_authenticate_user
      get :index
      response.should render_template(:index)
    end
  end
<% end %>
<% if action? :show %>
  describe "GET show" do
    it "should render show template" do
      stub_authenticate_user
      <%= instance_name %> = Factory(<%= instance_name(':') %>)
      get :show, :id => <%= instance_name %>.id.to_s
      response.should render_template(:show)
    end
  end
<% end %>
<% if action? :new %>
  describe "GET new" do
    it "should render new template" do
      stub_authenticate_user
      get :new
      response.should render_template(:new)
    end
  end
<% end %>
<% if action? :create %>
  describe "POST create" do
    describe "with valid params" do
      it "should redirect to show template" do
        stub_authenticate_user
        <%= class_name %>.any_instance.stub(:valid?).and_return(true)
        post :create, <%= instance_name(':') %> => Factory.attributes_for(<%= instance_name(':') %>)
        response.should redirect_to(<%= generate_route_link(:action => :show, :suffix => 'path', :object => "assigns(#{instance_name(':')})") %>)
      end
    end
    
    describe "with invalid params" do
      it "should re-render new template" do
        stub_authenticate_user
        <%= class_name %>.any_instance.stub(:valid?).and_return(false)
        post :create, <%= instance_name(':') %> => nil
        response.should render_template(:new)
      end
    end
  end
<% end %>
<% if action? :edit %>
  describe "GET edit" do
    it "should render edit template" do
      stub_authenticate_user
      <%= instance_name %> = Factory(<%= instance_name(':') %>)
      get :edit, :id => <%= instance_name %>.id.to_s
      response.should render_template(:edit)
    end
  end
<% end %>
<% if action? :update %>
  describe "PUT update" do
    describe "with valid params" do
      it "should redirect to show template" do
        stub_authenticate_user
        <%= instance_name %> = Factory(<%= instance_name(':') %>)
        <%= class_name %>.stub(:find).with(<%= instance_name %>.id.to_s).and_return(<%= instance_name %>)
        <%= class_name %>.any_instance.stub(:valid?).and_return(true)
        put :update, :id => <%= instance_name %>.id.to_s
        response.should redirect_to(<%= generate_route_link(:action => :show, :suffix => 'path', :object => "assigns(#{instance_name(':')})") %>)
      end
    end
    
    describe "with invalid params" do
      it "should re-render edit template" do
        stub_authenticate_user
        <%= instance_name %> = Factory(<%= instance_name(':') %>)
        <%= class_name %>.stub(:find).with(<%= instance_name %>.id.to_s).and_return(<%= instance_name %>)
        <%= class_name %>.any_instance.stub(:valid?).and_return(false)
        put :update, :id => <%= instance_name %>.id.to_s
        response.should render_template(:edit)
      end
    end
  end
<% end %>
<% if action? :destroy %>
  describe "DELETE destroy" do
    it "should redirect to index template" do
      stub_authenticate_user
      <%= instance_name %> = Factory(<%= instance_name(':') %>)
      delete :destroy, :id => <%= instance_name %>.id.to_s
      response.should redirect_to(<%= generate_route_link(:action => :index, :suffix => 'path') %>)
    end
  end
<% end %>
end