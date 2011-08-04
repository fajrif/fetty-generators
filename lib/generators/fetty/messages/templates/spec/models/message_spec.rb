require 'spec_helper'

describe Message do
  
  before(:each) do
    @message = Factory.build(:message)
  end
  
  it "should be valid" do
    @message.should be_valid
  end
  
  it "should have error on user_id if nil" do
    @message.user_id = nil
    @message.should have(1).error_on(:user_id)
  end
  
  it "should have error on sender_id if nil" do
    @message.sender_id = nil
    @message.should have(1).error_on(:sender_id)
  end
  
  it "should have error on recipient_id if nil" do
    @message.recipient_id = nil
    @message.should have(1).error_on(:recipient_id)
  end
  
  it "should have error on subject_id if nil" do
    @message.subject_id = nil
    @message.should have(1).error_on(:subject_id)
  end
  
  it "should have error on subject if nil" do
    @message.subject = nil
    @message.should have(1).error_on(:subject)
  end
  
  it "should have error on content if nil" do
    @message.content = nil
    @message.should have(1).error_on(:content)
  end
  
end

describe Message, "Class Methods" do
  it "subject id should increment by 1" do
    change{Message.sequence_subject_id}.from(0).to(1)
  end
end

describe Message, "Instance Methods" do
  
end