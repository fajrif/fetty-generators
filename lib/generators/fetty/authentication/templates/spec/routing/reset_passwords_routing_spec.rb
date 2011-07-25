require 'spec_helper'

describe ResetPasswordsController do
  describe "routing" do
    it "routes to #new" do
      get("/users/reset_password/new").should route_to("reset_passwords#new")
    end
    
    it "routes to #create" do
      post("/users/reset_password").should route_to("reset_passwords#create")
    end
    
    it "routes to #edit" do
      get("/users/reset_password/1/434343").should route_to("reset_passwords#edit", :id => "1", :token => "434343")
    end
    
    it "routes to #update" do
      put("/users/reset_password").should route_to("reset_passwords#update")
    end
  end
end