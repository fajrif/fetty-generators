require 'spec_helper'

describe <%= model_name %> do
  it "should be valid" do
    <%= instance_name('@') %> = <%= class_name %>.new
    <%= instance_name('@') %>.attributes = Factory.attributes_for(<%= instance_name(':') %>)
    <%= instance_name('@') %>.should be_valid
  end
end
