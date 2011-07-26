require 'spec_helper'

describe <%= controller_name %> do
<%- if action? :index -%>
  describe "GET index" do
    it "should render index template" do
      pending
    end
  end
<%- end -%>
<%- if action? :show -%>
  describe "GET show" do
    it "should render show template" do
      pending
    end
  end
<%- end -%>
<%- if action? :new -%>
  describe "GET new" do
    it "should render new template" do
      pending
    end
  end
<%- end -%>
<%- if action? :create -%>
  describe "POST create" do
    describe "with valid params" do
      it "should redirect to show template" do
        pending
      end
    end
    
    describe "with invalid params" do
      it "should re-render new template" do
        pending
      end
    end
  end
<%- end -%>
<%- if action? :edit -%>
  describe "GET edit" do
    it "should render edit template" do
      
    end
  end
<%- end -%>
<%- if action? :update -%>
  describe "PUT update" do
    describe "with valid params" do
      it "should redirect to show template" do
        pending
      end
    end
    
    describe "with invalid params" do
      it "should re-render edit template" do
        pending
      end
    end
  end
<%- end -%>
<%- if action? :destroy -%>
  describe "DELETE destroy" do
    it "should redirect to index template" do
      pending
    end
  end
<%- end -%>
end