require 'spec_helper'

describe "<%= model_name %>" do
  describe "GET /<%= model_name %>" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get <%= generate_route_link(:action => :index, :suffix => 'path') %>
      response.should be_success
    end
  end
end
