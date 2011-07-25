require 'spec_helper'

describe SessionsController do
  describe "routing" do
    it "routes to #new" do
      get("/users/session/new").should route_to("sessions#new")
    end
    
    it "routes to #create" do
      post("/users/session").should route_to("sessions#create")
    end
    
    it "routes to #destroy" do
      delete("/users/session").should route_to("sessions#destroy")
    end
  end
end