Gem::Specification.new do |s|
  s.name        = "fetty-generators"
  s.version     = "1.6.8"
  s.author      = "Fajri Fachriansyah"
  s.email       = "fajrif@hotmail.com"
  s.homepage    = "http://github.com/fajrif/fetty-generators"
  s.summary     = "This is a scaffold generators for you who working regularly with Devise, CanCan, simple-form, meta_search and jQuery-rails in Rails 3"
  s.description = "If you are the fan of Ryan bates screencasts show, use this scaffold generators for your rails application, this generators are inherited from nifty-generators, but change the form using simple-form and also create nice index page with feature like search, sort column and paginate."

  s.files        = Dir["{lib}/**/*", "[A-Z]*"]
  s.require_path = "lib"

  s.rubyforge_project = s.name
  # s.required_rubygems_version = ">= 1.3.4"
end
