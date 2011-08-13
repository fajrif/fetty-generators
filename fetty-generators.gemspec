# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "fetty-generators"
  s.version     = "2.0.1"
  s.authors     = ["Fajri Fachriansyah"]
  s.email       = ["fajri82@gmail.com"]
  s.homepage    = "http://github.com/fajrif/fetty-generators"
  s.summary     = %q{Simple generator to start your Rails project}
  s.description = %q{Simple generator to start your Rails project}
  s.rubyforge_project = s.name
    
  s.files        = Dir["{lib}/**/*", "[A-Z]*"]

  s.require_paths = ["lib"]
end
