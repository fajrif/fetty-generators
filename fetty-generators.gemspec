# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "fetty-generators"
  s.version     = "1.9.2"
  s.authors     = ["Fajri Fachriansyah"]
  s.email       = ["fajrif@hotmail.com"]
  s.homepage    = "http://github.com/fajrif/fetty-generators"
  s.summary     = %q{Simple generator to start your Rails project}
  s.description = %q{Simple generator to start your Rails project}
  s.rubyforge_project = s.name
    
  s.files        = Dir["{lib}/**/*", "[A-Z]*"]

  s.require_paths = ["lib"]
end
