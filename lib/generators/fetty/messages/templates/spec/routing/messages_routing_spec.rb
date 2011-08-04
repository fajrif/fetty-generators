require 'spec_helper'

describe MessagesController do
  describe "routing" do
    it "routes to #index" do
      get("/messages").should route_to("messages#index")
    end
    
    it "routes to #inbox" do
      get("/messages/inbox").should route_to("messages#index", :messagebox => "inbox")
    end
    
    it "routes to #outbox" do
      get("/messages/outbox").should route_to("messages#index", :messagebox => "outbox")
    end
    
    it "routes to #trash" do
      get("/messages/trash").should route_to("messages#index", :messagebox => "trash")
    end
    
    it "routes to #show_inbox" do
      get("/messages/inbox/show/1").should route_to("messages#show", :messagebox => "inbox", :id => "1")
    end
    
    it "routes to #show_outbox" do
      get("/messages/outbox/show/1").should route_to("messages#show", :messagebox => "outbox", :id => "1")
    end
    
    it "routes to #show_trash" do
      get("/messages/trash/show/1").should route_to("messages#show", :messagebox => "trash", :id => "1")
    end
    
    it "routes to #new" do
      get("/messages/new").should route_to("messages#new")
    end
    
    it "routes to #create" do
      post("/messages").should route_to("messages#create")
    end
    
    it "routes to #update" do
      put("/messages").should route_to("messages#update")
    end
    
    it "routes to #token" do
      get("/messages/token").should route_to("messages#token")
    end
    
    it "routes to #empty_inbox" do
      post("/messages/empty/inbox").should route_to("messages#empty", :messagebox => "inbox")
    end
    
    it "routes to #empty_outbox" do
      post("/messages/empty/outbox").should route_to("messages#empty", :messagebox => "outbox")
    end
    
    it "routes to #empty_trash" do
      post("/messages/empty/trash").should route_to("messages#empty", :messagebox => "trash")
    end
  end
end