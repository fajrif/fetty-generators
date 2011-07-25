Factory.define :user do |f|
  f.username "visitor"
  f.email "visitor@example.com"
  f.password "somepassword"
  f.password_confirmation { |u| u.password }
end
