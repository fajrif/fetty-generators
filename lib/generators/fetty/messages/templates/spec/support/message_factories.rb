Factory.define :message do |f|
  f.association :user, :factory => :user
  f.association :sender_id, :factory => :user
  f.association :recipient_id, :factory => :user
  f.subject_id 1
  f.subject "testing"
  f.content "This is only test !!"
end
