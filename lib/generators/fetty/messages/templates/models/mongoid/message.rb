class Message
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Ancestry
  
  has_ancestry
  
  belongs_to :user
  
  field :user_id, :type => String
  field :sender_id, :type => String
  field :recipient_id, :type => String
  field :subject_id, :type => String
  field :subject, :type => String
  field :content, :type => String
  field :opened, :type => Boolean, :default => false
  field :deleted, :type => Boolean, :default => false
  field :copies, :type => Boolean, :default => false
  field :ancestry, :type => String
  
  validates_presence_of :user_id, :sender_id, :recipient_id, :subject_id, :subject, :content
  
  attr_accessible :user_id,
                  :sender_id,
                  :recipient_id,
                  :subject_id,
                  :subject,
                  :content,
                  :opened,
                  :deleted,
                  :copies,
                  :parent_id
  
  def self.sequence_subject_id
    id = self.maximum(:subject_id).to_i
    id = 0 if id.nil?
    id += 1
    id
  end
  
  def self.next_parent_id(parent_id)
    parent_id = parent_id.to_i - 1
    if self.where(:id => parent_id).empty?
      parent_id = nil
    end
    parent_id
  end
  
  def read?
    self.opened?
  end

  def mark_as_read
    self.update_attributes!(:opened => true) 
  end

  def mark_as_unread
    self.update_attributes!(:opened => false)
  end
  
  def delete
    unless self.deleted?
      self.update_attributes!(:deleted => true) 
    else
      self.destroy
    end
  end

  def undelete
    self.update_attributes!(:deleted => false)
  end

  def from
    User.find_by_id(self.sender_id)
  end

  def to
    User.find_by_id(self.recipient_id)
  end 

end
